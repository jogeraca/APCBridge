# APC Bridge

Local control of APC SurgeArrest smart surge protectors, bridged to MQTT for
Home Assistant auto-discovery.

## Installation

1. Install the **Mosquitto broker** add-on (or any MQTT broker integrated with HA).
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
