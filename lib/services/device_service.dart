import 'dart:async';
import 'dart:math';
import '../models/device_item.dart';
import '../models/sensor.dart';

class DeviceService {
  final List<DeviceItem> _devices = [
    DeviceItem(id: '1', name: 'Dispositivo Sensor Invernadero 1 - Derecha', isOnline: true, lastSeen: 'Hace 5 minutos'),
    DeviceItem(id: '2', name: 'Dispositivo Sensor Invernadero 1 - Izquierda', isOnline: true, lastSeen: 'Hace 10 minutos'),
    DeviceItem(id: '3', name: 'Dispositivo Sensor Invernadero 2', isOnline: false, lastSeen: 'Hace 1 hora'),
  ];
 
  List<DeviceItem> getDevices() {
    return _devices;
  }

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