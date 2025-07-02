#!/usr/bin/env python
"""
Simulador RTDB • 5 dispositivos × 2 sensores (temperature & humidity)
Mantiene 10 sensores fijos (5 dispositivos × 2 sensores) con IDs consistentes.
Solo actualiza valores en tiempo real, sin crear/eliminar sensores.
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

SEND_EVERY_S = 2

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

def initialize_sensors(sensors_ref):
    """
    Inicializa los 10 sensores fijos si no existen.
    Cada sensor tiene un ID fijo basado en deviceId_sensorType.
    """
    print("Inicializando sensores fijos...")

    for dev in DEVICE_IDS:
        for sensor_name, cfg in SENSORS.items():
            sensor_id = f"{dev}_{sensor_name}"
            sensor_ref = sensors_ref.child(sensor_id)

            # Solo crear el sensor si no existe
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

def update_sensor_value(sensors_ref, device_id, sensor_name, cfg):
    """
    Actualiza solo el valor y timestamp de un sensor existente.
    """
    sensor_id = f"{device_id}_{sensor_name}"
    lo, hi = cfg["range"]
    value = round(random.uniform(lo, hi), 1)
    
    # Solo actualizar los campos que cambian
    update_data = {
        "value": value,
        "timestamp": int(time.time()),
    }
    
    sensors_ref.child(sensor_id).update(update_data)
    return value

def main() -> None:
    cred = credentials.Certificate(SERVICE_ACCOUNT_FILE)
    firebase_admin.initialize_app(cred, {"databaseURL": DATABASE_URL})
    root = db.reference()
    notifications_ref = root.child("notifications")
    sensors_ref = root.child("sensors")

    print("Simulador corriendo: 5 dispositivos × 2 sensores (Ctrl+C para detener)")
    print("Manteniendo 10 sensores fijos con IDs consistentes\n")

    # Inicializar sensores fijos al inicio
    initialize_sensors(sensors_ref)
    print("\nIniciando simulación de valores en tiempo real...\n")

    try:
        while True:
            tic = time.monotonic()

            for dev in DEVICE_IDS:
                dev_ref = root.child("devices").child(dev)
                device_sensors_ref = dev_ref.child("sensors")

                device_data = {
                    "name": f"Dispositivo {dev.upper()}",
                    "isOnline": True,
                    "lastSeen": iso_now(),
                }
                print("Actualizando dispositivo:", dev, device_data)
                dev_ref.update(device_data)

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

                    print("Actualizando sensor en dispositivo:",
                          dev, sensor_name, sample)
                    device_sensors_ref.child(sensor_name).set(sample)

                    # Actualizar sensor en el registro global (solo valor y timestamp)
                    value = update_sensor_value(sensors_ref, dev, sensor_name, cfg)
                    print(f"Valor actualizado en sensor global {dev}_{sensor_name}: {value}{cfg['unit']}")

                    if value > cfg["high_threshold"]:
                        notif = {
                            "deviceName": dev,
                            "message": f"{sensor_name.capitalize()} alta: {value}{cfg['unit']}",
                            "timestamp": iso_now(),
                            "severity": "high",
                        }
                        print("Enviando notificación:", notif)
                        notifications_ref.push(notif)
                        prune_notifications(notifications_ref, keep=5)

            sleep_time = SEND_EVERY_S - (time.monotonic() - tic)
            if sleep_time > 0:
                time.sleep(sleep_time)
    except KeyboardInterrupt:
        print("\nSimulación detenida.")

if __name__ == "__main__":
    main()
