#!/usr/bin/env bash
set -e

CONFIG_PATH=/data/options.json
DATA_DIR=/data

mkdir -p "$DATA_DIR"
cd "$DATA_DIR"

LOG_LEVEL=$(jq -r '.log_level // "info"' "$CONFIG_PATH")
APC_EMAIL=$(jq -r '.apc_email // ""' "$CONFIG_PATH")
APC_PASSWORD=$(jq -r '.apc_password // ""' "$CONFIG_PATH")
BIND_IP=$(jq -r '.bind_ip // ""' "$CONFIG_PATH")
MQTT_HOST=$(jq -r '.mqtt_host // ""' "$CONFIG_PATH")
MQTT_PORT=$(jq -r '.mqtt_port // 1883' "$CONFIG_PATH")
MQTT_USER=$(jq -r '.mqtt_user // ""' "$CONFIG_PATH")
MQTT_PASS=$(jq -r '.mqtt_pass // ""' "$CONFIG_PATH")

echo "[apcbridge] log_level=$LOG_LEVEL"

# Auto-discover MQTT from the Mosquitto add-on via Supervisor
if [[ -z "$MQTT_HOST" && -n "${SUPERVISOR_TOKEN:-}" ]]; then
    echo "[apcbridge] mqtt_host empty; querying Supervisor for MQTT service..."
    if MQTT_INFO=$(curl -fsSL -H "Authorization: Bearer $SUPERVISOR_TOKEN" http://supervisor/services/mqtt 2>/dev/null); then
        MQTT_HOST=$(echo "$MQTT_INFO" | jq -r '.data.host // ""')
        DISC_PORT=$(echo "$MQTT_INFO" | jq -r '.data.port // 1883')
        DISC_USER=$(echo "$MQTT_INFO" | jq -r '.data.username // ""')
        DISC_PASS=$(echo "$MQTT_INFO" | jq -r '.data.password // ""')
        [[ "$MQTT_PORT" == "1883" ]] && MQTT_PORT="$DISC_PORT"
        [[ -z "$MQTT_USER" ]] && MQTT_USER="$DISC_USER"
        [[ -z "$MQTT_PASS" ]] && MQTT_PASS="$DISC_PASS"
        echo "[apcbridge] Using Supervisor MQTT service at $MQTT_HOST:$MQTT_PORT"
    else
        echo "[apcbridge] WARNING: Supervisor MQTT service not reachable."
    fi
fi

if [[ -z "$MQTT_HOST" ]]; then
    echo "[apcbridge] ERROR: No MQTT host. Install the Mosquitto broker add-on or set 'mqtt_host'." >&2
    exit 1
fi

# First-run login: fetch device keys from the APC Home cloud if config.json is missing.
if [[ ! -f "$DATA_DIR/config.json" ]]; then
    if [[ -z "$APC_EMAIL" || -z "$APC_PASSWORD" ]]; then
        echo "[apcbridge] ERROR: $DATA_DIR/config.json missing and apc_email/apc_password are empty." >&2
        echo "[apcbridge] Set your APC Home account credentials in the add-on Configuration tab and restart." >&2
        exit 1
    fi
    echo "[apcbridge] First run — logging in with APC Home account $APC_EMAIL..."
    python3 /app/login.py "$APC_EMAIL" "$APC_PASSWORD"
fi

ARGS=(--mqtt-ip "$MQTT_HOST" --mqtt-port "$MQTT_PORT")
[[ -n "$MQTT_USER" ]] && ARGS+=(--mqtt-user "$MQTT_USER")
[[ -n "$MQTT_PASS" ]] && ARGS+=(--mqtt-pass "$MQTT_PASS")
[[ -n "$BIND_IP" ]]   && ARGS+=(--bind "$BIND_IP")

echo "[apcbridge] Starting APC Bridge..."
exec python3 /app/main.py "${ARGS[@]}"
