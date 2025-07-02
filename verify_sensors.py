#!/usr/bin/env python
"""
Script de verificación para la nueva estructura de sensores fijos.
Verifica que los 10 sensores estén correctamente configurados.
Requiere: pip install firebase-admin~=6.5
"""

import firebase_admin
from firebase_admin import credentials, db

SERVICE_ACCOUNT_FILE = "firebaseRTDB-key.json"
DATABASE_URL = "https://invernadero-iot-dfa2f-default-rtdb.firebaseio.com"

EXPECTED_DEVICE_IDS = [f"dev{i}" for i in range(1, 6)]
EXPECTED_SENSOR_TYPES = ["temperature", "humidity"]

def verify_sensors_structure():
    """
    Verifica que la estructura de sensores fijos esté correctamente configurada.
    """
    try:
        # Inicializar Firebase Admin
        cred = credentials.Certificate(SERVICE_ACCOUNT_FILE)
        firebase_admin.initialize_app(cred, {"databaseURL": DATABASE_URL})

        root = db.reference()
        sensors_ref = root.child("sensors")

        print("🔍 Verificando estructura de sensores fijos...")
        print("=" * 50)

        # Obtener todos los sensores
        all_sensors = sensors_ref.get() or {}

        if not all_sensors:
            print("❌ No se encontraron sensores en la base de datos.")
            print("   Ejecuta: python setup_fixed_sensors.py")
            return False

        print(f"📊 Total de sensores encontrados: {len(all_sensors)}")

        # Verificar que tenemos exactamente 10 sensores
        expected_count = len(EXPECTED_DEVICE_IDS) * len(EXPECTED_SENSOR_TYPES)
        if len(all_sensors) != expected_count:
            print(f"⚠️  Advertencia: Se esperaban {expected_count} sensores, pero se encontraron {len(all_sensors)}")

        # Verificar cada sensor esperado
        missing_sensors = []
        invalid_sensors = []
        valid_sensors = []

        for device_id in EXPECTED_DEVICE_IDS:
            for sensor_type in EXPECTED_SENSOR_TYPES:
                expected_id = f"{device_id}_{sensor_type}"

                if expected_id in all_sensors:
                    sensor_data = all_sensors[expected_id]

                    # Verificar campos requeridos
                    required_fields = ['id', 'deviceId', 'type', 'value', 'unit', 'timestamp', 'minValue', 'maxValue']
                    missing_fields = [field for field in required_fields if field not in sensor_data]

                    if missing_fields:
                        invalid_sensors.append((expected_id, f"Campos faltantes: {missing_fields}"))
                    elif (sensor_data['deviceId'] != device_id or
                          sensor_data['type'] != sensor_type or
                          sensor_data['id'] != expected_id):
                        invalid_sensors.append((expected_id, "Datos inconsistentes"))
                    else:
                        valid_sensors.append(expected_id)
                        print(f"  ✓ {expected_id}: {sensor_data['value']}{sensor_data['unit']} (válido)")
                else:
                    missing_sensors.append(expected_id)

        # Reportar resultados
        print("\n📈 Resumen de verificación:")
        print(f"  ✅ Sensores válidos: {len(valid_sensors)}")
        print(f"  ❌ Sensores faltantes: {len(missing_sensors)}")
        print(f"  ⚠️  Sensores inválidos: {len(invalid_sensors)}")

        if missing_sensors:
            print("\n❌ Sensores faltantes:")
            for sensor_id in missing_sensors:
                print(f"    - {sensor_id}")

        if invalid_sensors:
            print("\n⚠️  Sensores inválidos:")
            for sensor_id, reason in invalid_sensors:
                print(f"    - {sensor_id}: {reason}")

        # Verificar sensores extra (no esperados)
        expected_sensor_ids = {f"{device_id}_{sensor_type}"
                               for device_id in EXPECTED_DEVICE_IDS
                               for sensor_type in EXPECTED_SENSOR_TYPES}
        extra_sensors = set(all_sensors.keys()) - expected_sensor_ids

        if extra_sensors:
            print("\n⚠️  Sensores extra encontrados:")
            for sensor_id in extra_sensors:
                print(f"    - {sensor_id}")

        # Resultado final
        success = (len(valid_sensors) == expected_count and
                   len(missing_sensors) == 0 and
                   len(invalid_sensors) == 0)

        if success:
            print("\n🎉 ¡Verificación exitosa!")
            print("   La estructura de sensores fijos está correctamente configurada.")
            print("   Ya puedes usar la aplicación Flutter con: flutter run")
        else:
            print("\n❌ Verificación fallida.")
            print("   Ejecuta 'python setup_fixed_sensors.py' para reconfigurar.")

        return success

    except FileNotFoundError:
        print(f"❌ Error: No se encontró el archivo de credenciales '{SERVICE_ACCOUNT_FILE}'")
        print("   Asegúrate de que el archivo existe en el directorio actual.")
        return False
    except Exception as e:
        print(f"❌ Error inesperado: {e}")
        return False
    finally:
        # Limpiar la app de Firebase si fue inicializada
        try:
            firebase_admin.delete_app(firebase_admin.get_app())
        except ValueError:
            # App no fue inicializada
            pass

def main():
    print("🔥 Verificador de Estructura de Sensores Fijos")
    print("=" * 50)

    if verify_sensors_structure():
        print("\n✨ Todo listo para ejecutar la aplicación!")
    else:
        print("\n🔧 Necesitas reconfigurar los sensores.")

if __name__ == "__main__":
    main()
