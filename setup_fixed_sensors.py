#!/usr/bin/env python
"""
Script para configurar la estructura de sensores fijos en Firebase RTDB.
Crea 10 sensores fijos (5 dispositivos × 2 sensores cada uno) con IDs consistentes.
Requiere: pip install firebase-admin~=6.5
"""

import firebase_admin
from firebase_admin import credentials, db
import time

SERVICE_ACCOUNT_FILE = "firebaseRTDB-key.json"
DATABASE_URL = "https://invernadero-iot-dfa2f-default-rtdb.firebaseio.com"

DEVICE_IDS = [f"dev{i}" for i in range(1, 6)]
SENSORS = {
    "temperature": {
        "range": (15, 40),
        "unit": "°C",
        "initial_value": 25.0,
    },
    "humidity": {
        "range": (20, 90),
        "unit": "%",
        "initial_value": 60.0,
    },
}

def setup_fixed_sensors():
    """
    Configura los 10 sensores fijos con IDs consistentes.
    """
    try:
        # Inicializar Firebase Admin
        cred = credentials.Certificate(SERVICE_ACCOUNT_FILE)
        firebase_admin.initialize_app(cred, {"databaseURL": DATABASE_URL})

        root = db.reference()
        sensors_ref = root.child("sensors")

        print("🔧 Configurando estructura de sensores fijos...")
        print("=" * 50)

        # Limpiar sensores existentes primero
        print("🗑️  Limpiando sensores existentes...")
        sensors_ref.delete()

        # Crear los 10 sensores fijos
        sensors_created = 0

        for device_id in DEVICE_IDS:
            print(f"\n📱 Configurando sensores para dispositivo {device_id}:")

            for sensor_name, config in SENSORS.items():
                sensor_id = f"{device_id}_{sensor_name}"
                lo, hi = config["range"]

                sensor_data = {
                    "id": sensor_id,
                    "deviceId": device_id,
                    "type": sensor_name,
                    "value": config["initial_value"],
                    "unit": config["unit"],
                    "timestamp": int(time.time()),
                    "minValue": lo,
                    "maxValue": hi,
                }

                # Crear el sensor con ID fijo
                sensors_ref.child(sensor_id).set(sensor_data)
                sensors_created += 1

                print(f"  ✓ Creado: {sensor_id} - {config['initial_value']}{config['unit']}")

        print("\n🎉 Configuración completada!")
        print(f"📊 Total de sensores creados: {sensors_created}")
        print("🏷️  IDs de sensores:")

        for device_id in DEVICE_IDS:
            for sensor_name in SENSORS.keys():
                sensor_id = f"{device_id}_{sensor_name}"
                print(f"    - {sensor_id}")

        print("\n📝 Estructura en Firebase:")
        print("   /sensors/")
        for device_id in DEVICE_IDS:
            for sensor_name in SENSORS.keys():
                sensor_id = f"{device_id}_{sensor_name}"
                print(f"     ├── {sensor_id}/")
                print(f"     │   ├── id: {sensor_id}")
                print(f"     │   ├── deviceId: {device_id}")
                print(f"     │   ├── type: {sensor_name}")
                print(f"     │   ├── value: {SENSORS[sensor_name]['initial_value']}")
                print(f"     │   ├── unit: {SENSORS[sensor_name]['unit']}")
                print(f"     │   ├── minValue: {SENSORS[sensor_name]['range'][0]}")
                print(f"     │   ├── maxValue: {SENSORS[sensor_name]['range'][1]}")
                print(f"     │   └── timestamp: {int(time.time())}")

        print("\n✨ Los sensores están listos para recibir actualizaciones en tiempo real.")
        print("   Ahora puedes ejecutar el simulador con: python simulate_rtdb.py")

    except FileNotFoundError:
        print(f"❌ Error: No se encontró el archivo de credenciales '{SERVICE_ACCOUNT_FILE}'")
        print("   Asegúrate de que el archivo existe en el directorio actual.")
    except Exception as e:
        print(f"❌ Error inesperado: {e}")
    finally:
        # Limpiar la app de Firebase si fue inicializada
        try:
            firebase_admin.delete_app(firebase_admin.get_app())
        except ValueError:
            # App no fue inicializada
            pass

def main():
    print("🔥 Configurador de Sensores Fijos para Firebase RTDB")
    print("=" * 55)

    print("📋 Este script va a:")
    print("   1. Limpiar todos los sensores existentes en /sensors")
    print("   2. Crear 10 sensores fijos con IDs consistentes")
    print("   3. Configurar valores iniciales y rangos")
    print()

    response = input("¿Continuar? (y/N): ")
    if response.lower() in ['y', 'yes', 'sí', 'si']:
        setup_fixed_sensors()
    else:
        print("❌ Operación cancelada.")

if __name__ == "__main__":
    main()
