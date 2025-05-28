import 'package:flutter/material.dart';
import '../models/device_item.dart';

class DevicesViewModel extends ChangeNotifier {
  List<DeviceItem> _devices = [];
  List<DeviceItem> get devices => _devices;

  DevicesViewModel() {
    loadDevices();
  }

  Future<void> loadDevices() async {
    await Future.delayed(const Duration(seconds: 1));
    _devices = [
      const DeviceItem(
        id: 'dev1',
        name: 'Invernadero Principal',
        isOnline: true,
        lastSeen: 'hace 2 min',
        icon: Icons.eco,
      ),
      const DeviceItem(
        id: 'dev2',
        name: 'Estación Secundaria',
        isOnline: false,
        lastSeen: 'hace 1 h',
      ),
      const DeviceItem(
        id: 'dev3',
        name: 'Sensor Externo',
        isOnline: true,
        lastSeen: 'hace 30 s',
        icon: Icons.sensors,
      ),
    ];
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadDevices();
  }

  List<DeviceItem> search(String query) {
    if (query.isEmpty) return _devices;
    return _devices
        .where((d) => d.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
