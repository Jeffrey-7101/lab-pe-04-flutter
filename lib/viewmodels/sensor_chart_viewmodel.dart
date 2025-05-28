import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/sensor.dart';
import '../services/sensor_service.dart';

class SensorChartViewModel extends ChangeNotifier {
  final SensorService _service = SensorService();
  List<Sensor> sensors = [];
  Map<SensorType, List<Sensor>> sensorHistory = {
    SensorType.temperature: [],
    SensorType.humidity: [],
    SensorType.light: [],
    SensorType.co2: [],
  };
  final Duration historyWindow = const Duration(seconds: 30);
  Stream<List<Sensor>>? _sensorStream;
  StreamSubscription<List<Sensor>>? _subscription;

  SensorChartViewModel() {
    _initSensorStream();
  }

  void _initSensorStream() {
    _sensorStream = _service.getSensorData();
    _subscription = _sensorStream!.listen((data) {
      sensors = data;
      final now = DateTime.now();
      for (var sensor in data) {
        final list = sensorHistory[sensor.type]!;
        list.add(sensor);
        // Mantener solo los datos dentro de la ventana de tiempo
        list.removeWhere((s) => now.difference(s.timestamp) > historyWindow);
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}