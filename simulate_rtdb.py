#!/usr/bin/env python
"""
Simulador RTDB • 5 dispositivos × 2 sensores (temperature & humidity)
Mantiene solo 5 notificaciones en RTDB.
Requiere:  pip install firebase-admin~=6.5
"""

import random
import time
from datetime import datetime, timezone
import firebase_admin
from firebase_admin import credentials, db

SERVICE_ACCOUNT_FILE = "firebaseRTDB-key.json"
DATABASE_URL = "https://invernadero-iot-dfa2f-default-rtdb.firebaseio.com"

DEVICE_IDS = [f"dev{i}" for i in range(1, 6)]

SENSORS = {
    "temperature": {
        "range": (15, 40),
        "high_threshold": 35.0,
        "unit": "°C",
    },
    "humidity": {
        "range": (20, 90),
        "high_threshold": 80.0,
        "unit": "%",
    },
}

SEND_EVERY_S = 5

def iso_now() -> str:
    return datetime.now(timezone.utc).isoformat()

def prune_notifications(notifications_ref, keep=5):
    """
    Elimina las notificaciones más antiguas, dejando solo las 'keep' más recientes.
    Se basa en el campo 'timestamp' (ISO-8601), que ordena lexicográficamente.
    """
    all_notifs = notifications_ref.get() or {}
    items = list(all_notifs.items())
    items.sort(key=lambda kv: kv[1].get("timestamp", ""))
    for key, _ in items[:-keep]:
        notifications_ref.child(key).delete()

def main() -> None:
    cred = credentials.Certificate(SERVICE_ACCOUNT_FILE)
    firebase_admin.initialize_app(cred, {"databaseURL": DATABASE_URL})
    root = db.reference()
    notifications_ref = root.child("notifications")

    print("Simulador corriendo: 5 dispositivos × 2 sensores (Ctrl+C para detener)\n")

    try:
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
                    sample = {
                        "type": sensor_name,
                        "value": value,
                        "unit": cfg["unit"],
                        "timestamp": int(time.time()),
                        "minValue": lo,
                        "maxValue": hi,
                    }

                    sensors_ref.child(sensor_name).set(sample)
                    root.child("sensors").push({**sample, "deviceId": dev})

                    if value > cfg["high_threshold"]:
                        notif = {
                            "deviceName": dev,
                            "message": f"{sensor_name.capitalize()} alta: {value}{cfg['unit']}",
                            "timestamp": iso_now(),
                            "severity": "high",
                        }
                        notifications_ref.push(notif)
                        prune_notifications(notifications_ref, keep=5)

            sleep_time = SEND_EVERY_S - (time.monotonic() - tic)
            if sleep_time > 0:
                time.sleep(sleep_time)
    except KeyboardInterrupt:
        print("\nSimulación detenida.")

if __name__ == "__main__":
    main()
