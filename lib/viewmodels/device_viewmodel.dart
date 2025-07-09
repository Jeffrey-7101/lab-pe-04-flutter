import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/device_item.dart';
import '../models/sensor.dart';
import '../services/sensor_service.dart';

class DevicesViewModel extends ChangeNotifier {
  final _ref = FirebaseDatabase.instance.ref('devices');

  StreamSubscription<DatabaseEvent>? _sub;
  List<DeviceItem> _devices = [];
  List<DeviceItem> get devices => _devices;

  DevicesViewModel() {
    _listenDevices();
  }

  void _listenDevices() {
    _sub = _ref.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      _devices = data == null
          ? []
          : data.entries
              .map((e) => DeviceItem.fromJson(
                    e.key as String,
                    e.value as Map<dynamic, dynamic>,
                  ))
              .toList();

      notifyListeners();
    }, onError: (e) => debugPrint('Devices error: $e'));
  }

  DeviceItem getDeviceById(String id) {
    if (_devices.isEmpty) {
      return const DeviceItem(
        id: 'unknown',
        name: 'Sin datos',
        isOnline: false,
        lastSeen: '',
        sensors: [],
      );
    }
    return _devices.firstWhere(
      (d) => d.id == id,
      orElse: () => _devices[0],
    );
  }

  /// Ahora devuelve Future<void> para que pueda usarse con await
  Future<void> updateSensorLimits(
    String deviceId,
    SensorType type,
    double min,
    double max,
  ) async {
    final devIndex = _devices.indexWhere((d) => d.id == deviceId);
    if (devIndex == -1) return;

    final sensorIndex =
        _devices[devIndex].sensors.indexWhere((s) => s.type == type);
    if (sensorIndex == -1) return;

    // 1) Actualizo el modelo local y notifico
    _devices[devIndex].sensors[sensorIndex]
      ..minValue = min
      ..maxValue = max;
    notifyListeners();

    // Usar SensorService para actualizar límites
    SensorService.updateSensorLimits(deviceId, type, min, max);
  }

  void updateSensorActiveState(
    String deviceId,
    SensorType type,
    bool isActive,
  ) {
    final devIndex = _devices.indexWhere((d) => d.id == deviceId);
    if (devIndex == -1) return;

    final sensorIndex =
        _devices[devIndex].sensors.indexWhere((s) => s.type == type);
    if (sensorIndex == -1) return;

    _devices[devIndex].sensors[sensorIndex].actionIsActive = isActive;

    notifyListeners();

    // Usar SensorService para actualizar estado en Firebase
    SensorService.updateSensorActiveState(deviceId, type, isActive);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
