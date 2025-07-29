enum Granularity { fiveMinutes, hourly, daily, weekly, yearly }

extension GranularityExtension on Granularity {
  String get label {
    switch (this) {
      case Granularity.fiveMinutes:
        return '15 min';
      case Granularity.hourly:
        return 'Hora';
      case Granularity.daily:
        return 'Día';
      case Granularity.weekly:
        return 'Semana';
      case Granularity.yearly:
        return 'Año';
    }
  }

  String get pathSegment {
    switch (this) {
      case Granularity.fiveMinutes:
        return '5min';
      case Granularity.hourly:
        return 'hourly';
      case Granularity.daily:
        return 'daily';
      case Granularity.weekly:
        return 'monthly';
      case Granularity.yearly:
        return 'yearly';
    }
  }
}

class Statistic {
  final DateTime periodStart;
  final double minValue;
  final double maxValue;
  final double meanValue;
  final double countValue;

  Statistic({
    required this.periodStart,
    required this.minValue,
    required this.maxValue,
    required this.meanValue,
    required this.countValue,
  });

  factory Statistic.fromMap(Map<dynamic, dynamic> json) {
    final dt = DateTime.parse(json['timestamp'] as String);
    return Statistic(
      periodStart: dt,
      minValue:   (json['min']  as num).toDouble(),
      maxValue:   (json['max']  as num).toDouble(),
      meanValue:  (json['mean'] as num).toDouble(),
      countValue: (json['count']as num).toDouble(),
    );
  }
}
