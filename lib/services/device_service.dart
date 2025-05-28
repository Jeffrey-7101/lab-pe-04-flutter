import 'dart:async';
import 'dart:math';
import '../models/device.dart';
import '../models/sensor.dart';

class DeviceService {
  final List<Device> _devices = [
    Device(id: '1', name: 'Dispositivo Sensor Invernadero 1 - Derecha'),
    Device(id: '2', name: 'Dispositivo Sensor Invernadero 1 - Izquierda'),
    Device(id: '3', name: 'Dispositivo Sensor Invernadero 2'),
  ];
 
  List<Device> getDevices() {
    return _devices;
  }

  // Simula un stream de datos de sensores en tiempo real
  Stream<List<Sensor>> getSensorData(String deviceId) {
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
