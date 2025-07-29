import 'package:firebase_database/firebase_database.dart';
import '../models/statistic.dart';
import '../models/sensor.dart';

class StatisticsService {
  static final _db = FirebaseDatabase.instance;

  static Stream<List<Statistic>> streamStatistics({
    required String deviceId,
    required SensorType sensorType,
    required Granularity granularity,
  }) {
    final path = 'statistics'
        '/$deviceId'
        '/sensors'
        '/${deviceId}_${sensorType.name}'
        '/${granularity.pathSegment}';

    return _db.ref(path).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) return <Statistic>[];

      return data.entries
        .map((e) => Statistic.fromJson(e.key as String, e.value))
        .toList()
          ..sort((a, b) => a.periodStart.compareTo(b.periodStart));
    });
  }
}
