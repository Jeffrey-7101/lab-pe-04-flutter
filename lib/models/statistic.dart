enum Granularity { fiveMinutes, hourly, daily, weekly, yearly }

extension GranularityExtension on Granularity {
  String get label {
    switch (this) {
      case Granularity.fiveMinutes: return '5 min';
      case Granularity.hourly:     return 'Hora';
      case Granularity.daily:      return 'Día';
      case Granularity.weekly:     return 'Semana';
      case Granularity.yearly:     return 'Año';
    }
  }

  String get pathSegment {
    switch (this) {
      case Granularity.fiveMinutes: return '5min';
      case Granularity.hourly:      return 'hourly';
      case Granularity.daily:       return 'daily';
      case Granularity.weekly:      return 'weekly';
      case Granularity.yearly:      return 'yearly';
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

  factory Statistic.fromJson(String timestampKey, Map<dynamic, dynamic> json) {
    return Statistic(
      periodStart: DateTime.fromMillisecondsSinceEpoch(int.parse(timestampKey)),
      minValue:   (json['minValue']  as num).toDouble(),
      maxValue:   (json['maxValue']  as num).toDouble(),
      meanValue:  (json['meanValue'] as num).toDouble(),
      countValue: (json['countValue']as num).toDouble(),
    );
  }
}
