import 'package:flutter/material.dart';
import '../models/device_item.dart';
import '../models/sensor.dart';

class DevicesViewModel extends ChangeNotifier {
  List<DeviceItem> _devices = [];
  List<DeviceItem> get devices => _devices;

  DevicesViewModel() {
    loadDevices();
  }

  Future<void> loadDevices() async {
    await Future.delayed(const Duration(seconds: 1));
    _devices = [
      DeviceItem(
        id: 'dev1',
        name: 'Invernadero Principal',
        isOnline: true,
        lastSeen: 'hace 2 min',
        icon: Icons.eco,
        sensors: [
          Sensor(
            type: SensorType.humidity,
            value: 60.0,
            minValue: 40,
            maxValue: 70,
          ),
          Sensor(
            type: SensorType.temperature,
            value: 55.0,
            minValue: 20,
            maxValue: 54,
          ),
        ],
      ),
      DeviceItem(
        id: 'dev2',
        name: 'Estación Secundaria',
        isOnline: false,
        lastSeen: 'hace 1 h',
        sensors: [
          Sensor(
            type: SensorType.humidity,
            value: 30.0,
            minValue: 40,
            maxValue: 70,
          ),
        ],
      ),
      DeviceItem(
        id: 'dev3',
        name: 'Sensor Externo',
        isOnline: true,
        lastSeen: 'hace 30 s',
        icon: Icons.sensors,
        sensors: [],
      ),
    ];
    notifyListeners();
  }

  DeviceItem? getDeviceById(String id) {
    return _devices.firstWhere((d) => d.id == id, orElse: () => _devices[0]);
  }

  void updateSensorLimits(
    String deviceId,
    SensorType type,
    double min,
    double max,
  ) {
    final device = _devices.firstWhere((d) => d.id == deviceId);
    final sensor = device.sensors.firstWhere((s) => s.type == type);

    sensor.minValue = min;
    sensor.maxValue = max;
    notifyListeners();
  }
}
