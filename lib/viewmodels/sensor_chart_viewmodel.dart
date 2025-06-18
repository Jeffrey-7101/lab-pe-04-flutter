import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/sensor.dart';

class SensorChartViewModel extends ChangeNotifier {
  final _ref = FirebaseDatabase.instance.ref('sensors');
  final Duration historyWindow = const Duration(seconds: 30);

  StreamSubscription<DatabaseEvent>? _sub;

  List<Sensor> _sensors = const [];
  List<Sensor> get sensors => List.unmodifiable(_sensors);

  final Map<SensorType, List<Sensor>> sensorHistory = {
    for (var t in SensorType.values) t: <Sensor>[],
  };

  SensorChartViewModel() {
    _listenSensors();
  }

  void _listenSensors() {
    _sub = _ref.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      _sensors = _parseSensors(data);

      final now = DateTime.now();
      for (var s in _sensors) {
        final list = sensorHistory[s.type]!;
        list.add(s);
        list.removeWhere(
          (old) => now.difference(old.timestamp) > historyWindow,
        );
      }

      notifyListeners();
    }, onError: (e) => debugPrint('Sensors error: $e'));
  }

  List<Sensor> _parseSensors(Map<dynamic, dynamic>? data) {
    if (data == null) return const [];

    final List<Sensor> out = [];

    for (var entry in data.values) {
      if (entry is Map && entry['type'] != null) {
        out.add(Sensor.fromJson(entry));
        continue;
      }

      if (entry is Map) {
        for (var sub in entry.values) {
          if (sub is Map && sub['type'] != null) {
            out.add(Sensor.fromJson(sub));
          }
        }
      }
    }
    return out;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
