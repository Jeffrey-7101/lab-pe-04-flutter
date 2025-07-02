import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import '../models/sensor.dart';

class SensorService {
  static final _database = FirebaseDatabase.instance;
  
  /// Obtiene un sensor específico por su ID fijo
  static Future<Sensor?> getSensorById(String sensorId) async {
    try {
      final snapshot = await _database.ref('sensors/$sensorId').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return Sensor.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error obteniendo sensor $sensorId: $e');
      return null;
    }
  }
  
  /// Obtiene todos los sensores de un dispositivo específico
  static Stream<List<Sensor>> getSensorsForDevice(String deviceId) {
    return _database.ref('sensors').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return <Sensor>[];
      
      return data.entries
          .where((entry) {
            final sensorData = entry.value as Map<dynamic, dynamic>;
            return sensorData['deviceId'] == deviceId;
          })
          .map((entry) {
            final sensorData = entry.value as Map<dynamic, dynamic>;
            return Sensor.fromJson(sensorData);
          })
          .toList();
    });
  }
  
  /// Obtiene un sensor específico de un dispositivo y tipo
  static Stream<Sensor?> getSensorStream(String deviceId, SensorType sensorType) {
    final sensorId = '${deviceId}_${sensorType.name}';
    return _database.ref('sensors/$sensorId').onValue.map((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        return Sensor.fromJson(data);
      }
      return null;
    });
  }
  
  /// Actualiza los límites de un sensor específico
  static Future<void> updateSensorLimits(String deviceId, SensorType sensorType, 
      double minValue, double maxValue) async {
    try {
      final sensorId = '${deviceId}_${sensorType.name}';
      await _database.ref('sensors/$sensorId').update({
        'minValue': minValue,
        'maxValue': maxValue,
      });
      
      // También actualizar en la estructura del dispositivo
      await _database.ref('devices/$deviceId/sensors/${sensorType.name}').update({
        'minValue': minValue,
        'maxValue': maxValue,
      });
    } catch (e) {
      print('Error actualizando límites del sensor: $e');
      rethrow;
    }
  }

  // Mantener el método original para compatibilidad con código existente que pueda usarlo
  Stream<List<Sensor>> getSensorData() {
    final random = Random();
    return Stream.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      return [
        Sensor(
          type: SensorType.temperature,
          value: 20 + random.nextDouble() * 10,
          timestamp: now,
        ),
        Sensor(
          type: SensorType.humidity,
          value: 40 + random.nextDouble() * 20,
          timestamp: now,
        ),
        Sensor(
          type: SensorType.light,
          value: 500 + random.nextDouble() * 500,
          timestamp: now,
        ),
        Sensor(
          type: SensorType.co2,
          value: 350 + random.nextDouble() * 100,
          timestamp: now,
        ),
      ];
    });
  }
}
