import 'dart:async';
import 'package:flutter/material.dart';
import '../models/statistic.dart';
import '../models/sensor.dart';
import '../services/statistics_service.dart';

class StatisticsViewModel extends ChangeNotifier {
  final List<String> deviceIds = ['dev1', 'dev2', 'dev3', 'dev4', 'dev5'];
  String selectedDevice = 'dev1';

  final List<SensorType> sensorTypes = [
    SensorType.temperature,
    SensorType.humidity,
  ];
  
  SensorType selectedSensor = SensorType.humidity;

  final List<Granularity> granularities = Granularity.values;
  Granularity selectedGranularity = Granularity.hourly;

  StreamSubscription<List<Statistic>>? _sub;
  List<Statistic> statistics = [];

  StatisticsViewModel() {
    _listen();
  }

  void _listen() {
    _sub?.cancel();
    _sub = StatisticsService.streamStatistics(
      deviceId: selectedDevice,
      sensorType: selectedSensor,
      granularity: selectedGranularity,
    ).listen((list) {
      statistics = list;
      notifyListeners();
    }, onError: (e) {
      debugPrint('Error estadísticas: $e');
    });
  }

  void selectDevice(String dev) {
    selectedDevice = dev;
    _listen();
    notifyListeners();
  }

  void selectSensor(SensorType type) {
    selectedSensor = type;
    _listen();
    notifyListeners();
  }

  void selectGranularity(Granularity g) {
    selectedGranularity = g;
    _listen();
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
