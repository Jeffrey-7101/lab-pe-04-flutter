#!/usr/bin/env python
"""
Script para borrar completamente la colección /sensors de Firebase RTDB.
Ahora funciona con la nueva estructura de sensores fijos con IDs.
Requiere: pip install firebase-admin~=6.5
"""

import firebase_admin
from firebase_admin import credentials, db

SERVICE_ACCOUNT_FILE = "firebaseRTDB-key.json"
DATABASE_URL = "https://invernadero-iot-dfa2f-default-rtdb.firebaseio.com"

def clear_sensors_collection():
    """
    Borra completamente la colección /sensors de Firebase RTDB.
    """
    try:
        # Inicializar Firebase Admin
        cred = credentials.Certificate(SERVICE_ACCOUNT_FILE)
        firebase_admin.initialize_app(cred, {"databaseURL": DATABASE_URL})

        # Obtener referencia a la colección sensors
        root = db.reference()
        sensors_ref = root.child("sensors")

        # Verificar si existe la colección
        sensors_data = sensors_ref.get()

        if sensors_data is None:
            print("✓ La colección /sensors ya está vacía o no existe.")
            return

        # Contar los elementos antes de borrar
        sensor_count = len(sensors_data) if isinstance(sensors_data, dict) else 0
        print(f"📊 Encontrados {sensor_count} sensores en la colección /sensors")

        # Mostrar los IDs de los sensores que se van a borrar
        if isinstance(sensors_data, dict):
            print("🏷️  Sensores encontrados:")
            for sensor_id, sensor_data in sensors_data.items():
                device_id = sensor_data.get('deviceId', 'unknown')
                sensor_type = sensor_data.get('type', 'unknown')
                print(f"    - {sensor_id} ({device_id} - {sensor_type})")

        # Confirmar la operación
        print("\n⚠️  ATENCIÓN: Esta operación borrará TODOS los sensores fijos.")
        print("   Después de esto necesitarás ejecutar 'python setup_fixed_sensors.py' para recrearlos.")
        response = input("\n¿Estás seguro de que quieres borrar TODA la colección /sensors? (y/N): ")

        if response.lower() in ['y', 'yes', 'sí', 'si']:
            # Borrar toda la colección
            sensors_ref.delete()
            print("🗑️  La colección /sensors ha sido borrada completamente.")
            print("✓ Operación completada exitosamente.")
            print("\n📝 Próximos pasos:")
            print("   1. Ejecuta: python setup_fixed_sensors.py")
            print("   2. Luego ejecuta: python simulate_rtdb.py")
        else:
            print("❌ Operación cancelada por el usuario.")

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
    print("🔥 Script para borrar la colección /sensors de Firebase RTDB")
    print("=" * 55)
    clear_sensors_collection()

if __name__ == "__main__":
    main()
