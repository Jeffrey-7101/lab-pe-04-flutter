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

  void updateSensorLimits(
    String deviceId,
    SensorType type,
    double min,
    double max,
  ) {
    final devIndex = _devices.indexWhere((d) => d.id == deviceId);
    if (devIndex == -1) return;

    final sensorIndex =
        _devices[devIndex].sensors.indexWhere((s) => s.type == type);
    if (sensorIndex == -1) return;

    _devices[devIndex].sensors[sensorIndex]
      ..minValue = min
      ..maxValue = max;

    notifyListeners();

    // Convertir el tipo de sensor al nombre de nodo correcto que usa el simulador
    final String sensorNodeName = _getSensorNodeName(type);
    
    // Actualizar en Firebase
    _ref
        .child(deviceId)
        .child('sensors')
        .child(sensorNodeName)
        .update({'minValue': min, 'maxValue': max})
        .then((_) => debugPrint('Límites de sensor actualizados correctamente'))
        .catchError((error) => debugPrint('Error al actualizar límites: $error'));
  }
  
  // Obtiene el nombre del nodo de sensor en Firebase
  String _getSensorNodeName(SensorType type) {
    switch (type) {
      case SensorType.temperature:
        return 'temperature';
      case SensorType.humidity:
        return 'humidity';
      case SensorType.light:
        return 'light';
      case SensorType.co2:
        return 'co2';
      default:
        return type.name; // Fallback al nombre del enum
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
