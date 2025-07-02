enum SensorType { temperature, humidity, light, co2 }

class Sensor {
  final String? id; // ID único para identificar el sensor
  final SensorType type;
  double value;
  DateTime timestamp;
  double maxValue;
  double minValue;
  final String? deviceId; // ID del dispositivo al que pertenece

  Sensor({
    this.id,
    required this.type,
    required this.value,
    this.maxValue = 100.0,
    this.minValue = 0.0,
    this.deviceId,
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
      id: json['id'] as String?,
      type: _parseType(json['type'] as String),
      value: (json['value'] as num).toDouble(),
      minValue: (json['minValue'] as num?)?.toDouble() ?? 0.0,
      maxValue: (json['maxValue'] as num?)?.toDouble() ?? 100.0,
      deviceId: json['deviceId'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        ((json['timestamp'] ?? 0) as int) * 1000,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'type': type.name,
        'value': value,
        'minValue': minValue,
        'maxValue': maxValue,
        if (deviceId != null) 'deviceId': deviceId,
        'timestamp': timestamp.millisecondsSinceEpoch ~/ 1000,
      };

  static SensorType _parseType(String raw) =>
      SensorType.values.firstWhere((e) => e.name == raw,
          orElse: () => SensorType.temperature);
}
