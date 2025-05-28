enum SensorType { temperature, humidity }

class Sensor {
  final SensorType type;
  double value;
  DateTime timestamp;
  final double maxValue;
  final double minValue;

  Sensor({
    required this.type,
    required this.value,
    required this.maxValue,
    required this.minValue,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isValueInRange => value >= minValue && value <= maxValue;

  String get status {
    if (value < minValue) return "Demasiado bajo";
    if (value > maxValue) return "Demasiado alto";
    return "Óptimo";
  }
}
