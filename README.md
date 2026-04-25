# Ayla Local API Reverse Engineering

This is a reverse engineering of the Ayla IoT local API for the now discontinued and unsupported APC SurgeArrest smart surge protector.  The implementation initiates a connection with the device using the local api key exchange algorithm and can retrieve status updates, and it can also send commands to turn on/off the outlets/usb ports via MQTT, and is compatible with HomeAssistant.

Currently, it is required to use the app (you can find the APC Home apk online since it has been pulled from the play store) to initially setup the device, and the Ayla API to retrieve the local key for the device. 

This has been tested in a limited capacity with only an APC (Schneider Electric) Smart Surge Protector, as that is the only Ayla device that I have, although it may work with other devices that use the same platform.

## Install as a Home Assistant OS add-on (recommended)

1. In Home Assistant, go to **Settings → Add-ons → Add-on Store**.
2. Three-dot menu → **Repositories** → add `https://github.com/jogeraca/APCBridge`.
3. Install **APC Bridge**.
4. In the add-on **Configuration** tab, set `apc_email` and `apc_password`
   (your **APC Home** account credentials). MQTT is auto-discovered from the
   Mosquitto broker add-on if it's installed.
5. Start the add-on. On first run it logs in with your APC Home account,
   fetches your device keys to `/data/config.json`, then starts the local
   bridge. Outlets appear automatically in HA via MQTT discovery.

After the first successful start you can clear the APC Home credentials in the
add-on config — the device keys are cached in the add-on's persistent `/data`.

See [`apcbridge/DOCS.md`](apcbridge/DOCS.md) for full add-on documentation.

## Setup (plain Docker / docker compose)

1. Copy the example environment file and fill in your values:

   ```bash
   cp env.example .env
   ```

   Edit `.env` to set `BIND_IP`, `MQTT_IP`, `MQTT_USER`, and `MQTT_PASS`.

2. Build the Docker image:

   ```bash
   docker compose build
   ```

3. Retrieve the device's local key by logging in with your APC Home account credentials:

   ```bash
   docker compose run --rm --entrypoint python3 apc-bridge /app/login.py "you@example.com" "your_password"
   ```

   This writes `data/config.json` containing the auth token and device list.

4. Start the bridge:

   ```bash
   docker compose up -d
   ```

## Todo
- Implement WiFi setup?
