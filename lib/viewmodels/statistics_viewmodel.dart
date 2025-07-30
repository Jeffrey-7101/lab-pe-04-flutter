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
  bool isCustom = false;
  DateTimeRange? customRange;

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
    ).listen((allStats) {
      final now = DateTime.now();
      DateTime start;
      DateTime end;

      if (isCustom && customRange != null) {
        start = customRange!.start;
        end = customRange!.end;
      } else {
        end = now;
        switch (selectedGranularity) {
          case Granularity.fiveMinutes:
            start = now.subtract(const Duration(minutes: 1440));
            break;
          case Granularity.hourly:
            start = now.subtract(const Duration(hours: 24));
            break;
          case Granularity.daily:
            start = now.subtract(const Duration(days: 7));
            break;
          case Granularity.weekly:
            start = now.subtract(const Duration(days: 28));
            break;
          case Granularity.yearly:
            start = now.subtract(const Duration(days: 1095));
            break;
        }
      }

      statistics = allStats.where((s) {
        final ts = s.periodStart;
        return ts.isAfter(start) && ts.isBefore(end);
      }).toList()
        ..sort((a, b) => a.periodStart.compareTo(b.periodStart));

      notifyListeners();
    }, onError: (e) {
      debugPrint('Error estadísticas: $e');
    });
  }

  void selectDevice(String dev) {
    selectedDevice = dev;
    isCustom = false;
    customRange = null;
    _listen();
    notifyListeners();
  }

  void selectSensor(SensorType type) {
    selectedSensor = type;
    isCustom = false;
    customRange = null;
    _listen();
    notifyListeners();
  }

  void selectGranularity(Granularity g) {
    selectedGranularity = g;
    isCustom = false;
    customRange = null;
    _listen();
    notifyListeners();
  }

  void selectCustomRange(DateTimeRange range) {
    customRange = range;
    isCustom = true;
    final diff = range.end.difference(range.start);

    if (diff <= const Duration(hours: 1)) {
      selectedGranularity = Granularity.fiveMinutes;
    } else if (diff <= const Duration(days: 1)) {
      selectedGranularity = Granularity.hourly;
    } else if (diff <= const Duration(days: 7)) {
      selectedGranularity = Granularity.daily;
    } else if (diff <= const Duration(days: 30)) {
      selectedGranularity = Granularity.weekly;
    } else {
      selectedGranularity = Granularity.yearly;
    }

    _listen();
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
