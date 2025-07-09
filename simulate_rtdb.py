#!/usr/bin/env python
"""
Simulador RTDB • 5 dispositivos × 2 sensores (temperature & humidity)
Cada sensor se actualiza individualmente cada 2 segundos.
Requiere:  pip install firebase-admin~=6.5
"""

import random
import time
import threading
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

<<<<<<< HEAD
SEND_EVERY_S = 5
=======
SEND_EVERY_S = 2  # intervalo en segundos para cada sensor
>>>>>>> 6cd6feed0c2e27cbd36085e7d0a6a64025588ef7

def iso_now() -> str:
    return datetime.now(timezone.utc).isoformat()

def prune_notifications(notifications_ref, keep=5):
    all_notifs = notifications_ref.get() or {}
    items = list(all_notifs.items())
    items.sort(key=lambda kv: kv[1].get("timestamp", ""))
    for key, _ in items[:-keep]:
        notifications_ref.child(key).delete()

def initialize_sensors(sensors_ref):
    print("Inicializando sensores fijos...")
    for dev in DEVICE_IDS:
        for sensor_name, cfg in SENSORS.items():
            sensor_id = f"{dev}_{sensor_name}"
            sensor_ref = sensors_ref.child(sensor_id)
            if sensor_ref.get() is None:
                lo, hi = cfg["range"]
                initial_value = round(random.uniform(lo, hi), 1)
                sensor_data = {
                    "id": sensor_id,
                    "deviceId": dev,
                    "type": sensor_name,
                    "value": initial_value,
                    "unit": cfg["unit"],
                    "timestamp": int(time.time()),
                    "minValue": lo,
                    "maxValue": hi,
                }
                sensor_ref.set(sensor_data)
                print(f"Creado sensor fijo: {sensor_id}")
            else:
                print(f"Sensor ya existe: {sensor_id}")

def update_sensor(dev: str, sensor_name: str, cfg: dict, root_ref) -> None:
    """
    Actualiza cada sensor cada 2 segundos en su propio hilo.
    Se actualiza en el nodo del dispositivo y también en el registro global.
    """
    sensors_ref = root_ref.child("sensors")
    notifications_ref = root_ref.child("notifications")
    dev_ref = root_ref.child("devices").child(dev)
    device_sensors_ref = dev_ref.child("sensors")

    while True:
        # Actualizar dispositivo
        device_data = {
            "name": f"Dispositivo {dev.upper()}",
            "isOnline": True,
            "lastSeen": iso_now(),
        }
        dev_ref.update(device_data)

        # Actualizar sensor en el dispositivo
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
        device_sensors_ref.child(sensor_name).set(sample)

        # Actualizar sensor global (solo value y timestamp)
        sensor_id = f"{dev}_{sensor_name}"
        update_data = {
            "value": value,
            "timestamp": int(time.time()),
        }
        sensors_ref.child(sensor_id).update(update_data)
        print(f"[{iso_now()}] {sensor_id} actualizado: {value}{cfg['unit']}")

        # Enviar notificación si se supera el umbral
        if value > cfg["high_threshold"]:
            notif = {
                "deviceName": dev,
                "message": f"{sensor_name.capitalize()} alta: {value}{cfg['unit']}",
                "timestamp": iso_now(),
                "severity": "high",
            }
            notifications_ref.push(notif)
            prune_notifications(notifications_ref, keep=5)
            print(f"[{iso_now()}] Notificación enviada para {sensor_id}")

        time.sleep(SEND_EVERY_S)

def main() -> None:
    cred = credentials.Certificate(SERVICE_ACCOUNT_FILE)
    firebase_admin.initialize_app(cred, {"databaseURL": DATABASE_URL})
    root = db.reference()

    sensors_ref = root.child("sensors")
    initialize_sensors(sensors_ref)

    print("Iniciando simulación con hilos (cada sensor cada 2 segundos)...\n")

    # Iniciar un hilo por cada sensor
    threads = []
    for dev in DEVICE_IDS:
        for sensor_name, cfg in SENSORS.items():
            t = threading.Thread(target=update_sensor, args=(dev, sensor_name, cfg, root))
            t.daemon = True
            t.start()
            threads.append(t)

    try:
        # Mantener el hilo principal activo
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\nSimulación detenida.")

if __name__ == "__main__":
    main()
