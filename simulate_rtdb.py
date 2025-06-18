#!/usr/bin/env python
"""
Simulador RTDB • 5 dispositivos × 2 sensores (temperature & humidity)
Requiere:  pip install firebase-admin~=6.5
"""

import random
import time
from datetime import datetime, timezone
import firebase_admin
from firebase_admin import credentials, db

SERVICE_ACCOUNT_FILE = "invernadero-iot-dfa2f-firebase-adminsdk-fbsvc-286f031de9.json"           # ← tu JSON
DATABASE_URL = "https://invernadero-iot-dfa2f-default-rtdb.firebaseio.com"

DEVICE_IDS = [f"dev{i}" for i in range(1, 6)]  # dev1…dev5

SENSORS = {
    "temperature": {               # °C
        "range": (15, 40),
        "high_threshold": 35.0,    # notificación > 35 °C
        "unit": "°C",
    },
    "humidity": {                  # %
        "range": (20, 90),
        "high_threshold": 80.0,    # notificación > 80 %
        "unit": "%",
    },
}

SEND_EVERY_S = 1 


def iso_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def main() -> None:
    cred = credentials.Certificate(SERVICE_ACCOUNT_FILE)
    firebase_admin.initialize_app(cred, {"databaseURL": DATABASE_URL})
    root = db.reference()

    print("Simulador corriendo: 5 dispositivos × 2 sensores (Ctrl+C para detener)\n")

    while True:
        tic = time.monotonic()

        for dev in DEVICE_IDS:
            dev_ref = root.child("devices").child(dev)
            sensors_ref = dev_ref.child("sensors")

            dev_ref.update({
                "name": f"Dispositivo {dev.upper()}",
                "isOnline": True,
                "lastSeen": iso_now(),
            })

            for sensor_name, cfg in SENSORS.items():
                lo, hi = cfg["range"]
                value = round(random.uniform(lo, hi), 1)
                payload = {
                    "type": sensor_name,
                    "value": value,
                    "unit": cfg["unit"],
                    "timestamp": int(time.time()),
                    "minValue": lo,
                    "maxValue": hi,
                }

                sensors_ref.child(sensor_name).set(payload)

                root.child("sensors").push({**payload, "deviceId": dev})

                if value > cfg["high_threshold"]:
                    notif = {
                        "deviceName": dev,
                        "message": f"{sensor_name.capitalize()} alta: {value}{cfg['unit']}",
                        "timestamp": iso_now(),
                        "severity": "high",
                    }
                    root.child("notifications").push(notif)

        time.sleep(max(0, SEND_EVERY_S - (time.monotonic() - tic)))


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nSimulación detenida.")
