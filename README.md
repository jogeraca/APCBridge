# Ayla Local API Reverse Engineering

This is a reverse engineering of the Ayla IoT local API for the now discontinued and unsupported APC SurgeArrest smart surge protector.  The implementation initiates a connection with the device using the local api key exchange algorithm and can retrieve status updates, and it can also send commands to turn on/off the outlets/usb ports via MQTT, and is compatible with HomeAssistant.

Currently, it is required to use the app (you can find the APC Home apk online since it has been pulled from the play store) to initially setup the device, and the Ayla API to retrieve the local key for the device. 

This has been tested in a limited capacity with only an APC (Schneider Electric) Smart Surge Protector, as that is the only Ayla device that I have, although it may work with other devices that use the same platform.

## Setup

1. Copy the example environment file and fill in your values:

   ```bash
   cp env.example .env
   ```

   Edit `.env` to set `BIND_IP`, `MQTT_IP`, `MQTT_USER`, and `MQTT_PASS`.

2. Build the Docker image:

   ```bash
   docker compose build
   ```

3. Retrieve the device's local key by logging into the Ayla cloud. Replace the email and password with your APC Home account credentials:

   ```bash
   docker compose run --rm apc-bridge python3 /app/login.py "you@example.com" "your_password"
   ```

   This writes `data/config.json` containing the auth token and device list.

4. Start the bridge:

   ```bash
   docker compose up -d
   ```

## Todo
- Implement WiFi setup?
