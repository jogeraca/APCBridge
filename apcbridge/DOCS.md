# APC Bridge

Local control of APC SurgeArrest smart surge protectors, bridged to MQTT for
Home Assistant auto-discovery.

## Prerequisites — MQTT broker

APC Bridge **does not** install or include an MQTT broker. It declares
`services: mqtt:need` in its config, which means the Supervisor will refuse
to start it until an MQTT broker is available on your Home Assistant
instance. Before installing APC Bridge you must have:

1. **An MQTT broker running.** The recommended option is the official
   **Mosquitto broker** add-on.
2. **The MQTT integration configured** in Home Assistant so other add-ons
   (including this one) can auto-discover the broker.

### Install and configure Mosquitto broker

1. In Home Assistant, go to **Settings → Add-ons → Add-on Store**.
2. Search for **Mosquitto broker** (it lives under "Official add-ons").
3. Click **Install**, wait for it to finish, then click **Start**.
4. Enable **Start on boot** and **Watchdog** on the Info tab.
5. Go to **Settings → Devices & Services**. Home Assistant should show a
   discovered **MQTT** integration — click **Configure** and accept the
   defaults to finish the setup. If it isn't auto-discovered, click
   **Add Integration → MQTT** and use:
   - Broker: `core-mosquitto`
   - Port: `1883`
   - Username / password: an HA user (or create one in
     **Settings → People** dedicated to MQTT).

Once Mosquitto is running and the MQTT integration is configured, APC
Bridge will pick up the broker credentials automatically through the
Supervisor — you can leave `mqtt_host`, `mqtt_user` and `mqtt_pass`
**empty** in the APC Bridge configuration.

> Only set `mqtt_host` / `mqtt_user` / `mqtt_pass` manually if you are
> using an external MQTT broker that is **not** managed by the Supervisor.

## Installation

1. Make sure the prerequisites above are met (Mosquitto running + MQTT
   integration configured).
2. In Home Assistant, go to **Settings → Add-ons → Add-on Store**.
3. Click the three-dot menu → **Repositories** and add:
   `https://github.com/jogeraca/APCBridge`
4. Install **APC Bridge** from the store.
5. Open the add-on → **Configuration** tab and set:
   - `apc_email`: email of your **APC Home** account
   - `apc_password`: password of your **APC Home** account
6. Start the add-on and watch the **Log** tab. On first start it logs in with
   your APC Home account, downloads your device keys, and starts the local
   bridge.

Your APC outlets/USB ports should appear automatically in Home Assistant via
MQTT discovery as switches.

After the first successful start you can clear `apc_email` and `apc_password`
— the local key is cached in `/data/config.json`.

## Configuration

| Option | Description | Default |
| --- | --- | --- |
| `apc_email` | Email of your APC Home account. Required only on first start to fetch device keys. | `""` |
| `apc_password` | Password of your APC Home account. | `""` |
| `bind_ip` | IP the bridge listens on for the APC device callback. Auto-detected if empty. | `""` |
| `mqtt_host` | MQTT broker host. Empty = auto-discover the Mosquitto add-on via Supervisor. | `""` |
| `mqtt_port` | MQTT broker port. | `1883` |
| `mqtt_user` | MQTT username. Empty = use the credentials from the Mosquitto add-on. | `""` |
| `mqtt_pass` | MQTT password. | `""` |
| `log_level` | Add-on log verbosity. | `info` |

## Persistent state

Login data (auth token, device keys, MQTT settings) is kept at
`/data/config.json` inside the add-on. It survives restarts and updates.
Uninstalling the add-on wipes it.

## Network

The add-on uses **host networking** because the APC SurgeArrest device calls
back to the bridge on the LAN. Make sure Home Assistant is on the same network
segment as the device.

## First-time device pairing

This add-on does **not** perform the initial device setup. You must first
provision the APC SurgeArrest with the original APC Home mobile app so that
the device is associated with your APC Home account. After that, this add-on
can take over local control.
