import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/device_item.dart';
import '../models/sensor.dart';

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

    // 2) Persisto los cambios en Firebase
    await _updateSensorLimitsInFirebase(deviceId, type, min, max);
  }

  Future<void> _updateSensorLimitsInFirebase(
    String deviceId,
    SensorType type,
    double min,
    double max,
  ) async {
    try {
      final sensorId = '${deviceId}_${type.name}';

      // Actualizar en el nodo 'sensors/...'
      await _ref.root
          .child('sensors')
          .child(sensorId)
          .update({'minValue': min, 'maxValue': max});

      // También actualizar en la rama del dispositivo
      await _ref
          .child(deviceId)
          .child('sensors')
          .child(type.name)
          .update({'minValue': min, 'maxValue': max});

      debugPrint('Límites de sensor actualizados correctamente para $sensorId');
    } catch (error) {
      debugPrint('Error al actualizar límites: $error');
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
