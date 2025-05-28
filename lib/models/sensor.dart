enum SensorType {
  temperature,
  humidity,
  light,
  co2,
}

class Sensor {
  final SensorType type;
  final double value;
  final DateTime timestamp;

  Sensor({
    required this.type,
    required this.value,
    required this.timestamp,
  });

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
      // default:
      //   return 'Desconocido';
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
      // default:
      //   return '';
    }
  }

  String getFormattedValue() {
    return '${value.toStringAsFixed(1)} ${getUnit()}';
  }
}
