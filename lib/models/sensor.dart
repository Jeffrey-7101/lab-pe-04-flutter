enum SensorType { temperature, humidity, light, co2 }

class Sensor {
  final SensorType type;
  double value;
  DateTime timestamp;
  double maxValue;
  double minValue;

  Sensor({
    required this.type,
    required this.value,
    this.maxValue = 100.0,
    this.minValue = 0.0,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isValueInRange => value >= minValue && value <= maxValue;

  String get status {
    if (value < minValue) return "Demasiado bajo";
    if (value > maxValue) return "Demasiado alto";
    return "Óptimo";
  }

  String getLabel() {
    switch (type) {
      case SensorType.temperature:
        return 'Temperatura';
      case SensorType.humidity:
        return 'Humedad';
      case SensorType.light:
        return 'Luz';
      case SensorType.co2:
        return 'CO₂';
    }
  }

  String getUnit() {
    switch (type) {
      case SensorType.temperature:
        return '°C';
      case SensorType.humidity:
        return '%';
      case SensorType.light:
        return 'lx';
      case SensorType.co2:
        return 'ppm';
    }
  }

  String getFormattedValue() =>
      '${value.toStringAsFixed(1)} ${getUnit()}';

  factory Sensor.fromJson(Map<dynamic, dynamic> json) {
    return Sensor(
      type: _parseType(json['type'] as String),
      value: (json['value'] as num).toDouble(),
      minValue: (json['minValue'] as num?)?.toDouble() ?? 0.0,
      maxValue: (json['maxValue'] as num?)?.toDouble() ?? 100.0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        ((json['timestamp'] ?? 0) as int) * 1000,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'value': value,
        'minValue': minValue,
        'maxValue': maxValue,
        'timestamp': timestamp.millisecondsSinceEpoch ~/ 1000,
      };

  static SensorType _parseType(String raw) =>
      SensorType.values.firstWhere((e) => e.name == raw,
          orElse: () => SensorType.temperature);
}
