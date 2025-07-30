import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/sensor.dart';

class SensorChartViewModel extends ChangeNotifier {
  final String deviceId;
  final SensorType sensorType;
  final Duration historyWindow;

  late final DatabaseReference _sensorRef;
  StreamSubscription<DatabaseEvent>? _sub;

  final List<Sensor> history = [];
  Sensor? currentSensor;

  SensorChartViewModel({
    required this.deviceId,
    required this.sensorType,
    this.historyWindow = const Duration(seconds: 30),
  }) {
    // Escuchar el sensor con el nuevo formato de path
    final sensorPath = '/devices/$deviceId/sensors/${sensorType.name}/';

    // log
    debugPrint('Listening to path: $sensorPath');

    _sensorRef = FirebaseDatabase.instance.ref(sensorPath);

    _listen();
  }

  void _listen() {
    _sub = _sensorRef.onValue.listen((event) {
      final json = event.snapshot.value as Map<dynamic, dynamic>?;

      if (json != null) {
        final sample = Sensor.fromJson(json);
        currentSensor = sample;

        debugPrint('Sensor updated: ${sample.getFormattedValue()}');

        // Agregar al historial para el gráfico
        history.add(sample);
        final now = DateTime.now();
        history.removeWhere(
          (s) => now.difference(s.timestamp) > historyWindow,
        );

        notifyListeners();
      }
    }, onError: (e) {
      debugPrint('SensorChart error: $e');
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
