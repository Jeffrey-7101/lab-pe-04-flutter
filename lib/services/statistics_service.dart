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
    final path = 'device_stats'
        '/${deviceId}_${sensorType.name}'
        '/${granularity.pathSegment}';

    return _db.ref(path).onValue.map((event) {
      final raw = event.snapshot.value as Map<dynamic, dynamic>?;

      if (raw == null) return <Statistic>[];

      final List<Statistic> stats = [];

      raw.forEach((key, val) {
        if (val is Map) {
          if (val.containsKey('min')) {
            stats.add(Statistic.fromMap(val));
          } else {
            (val as Map<dynamic, dynamic>).forEach((_, subVal) {
              if (subVal is Map && subVal.containsKey('min')) {
                stats.add(Statistic.fromMap(subVal));
              }
            });
          }
        }
      });

      stats.sort((a, b) => a.periodStart.compareTo(b.periodStart));
      return stats;
    });
  }
}
