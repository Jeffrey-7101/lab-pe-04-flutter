import 'package:flutter/material.dart';
import 'sensor.dart';

class DeviceItem {
  final String id;
  final String name;
  final bool isOnline;
  final String lastSeen;
  final IconData icon;
  final List<Sensor> sensors;

  const DeviceItem({
    required this.id,
    required this.name,
    required this.isOnline,
    required this.lastSeen,
    this.icon = Icons.sensors,
    this.sensors = const [],
  });

  factory DeviceItem.fromJson(
    String id,
    Map<dynamic, dynamic> json,
  ) {
    final sensorsMap = json['sensors'] as Map<dynamic, dynamic>? ?? {};
    final iconName = json['icon'] as String?;

    return DeviceItem(
      id: id,
      name: json['name'] as String? ?? '',
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: json['lastSeen'] as String? ?? '',
      icon: _iconFromName(iconName) ?? Icons.sensors,
      sensors: sensorsMap.entries
          .map(
            (e) => Sensor.fromJson(e.value as Map<dynamic, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'isOnline': isOnline,
        'lastSeen': lastSeen,
        'icon': _nameFromIcon(icon),
        'sensors': {
          for (var s in sensors) s.type.name: s.toJson(),
        },
      };

  /// Mapa de nombres de íconos a IconData
  static const Map<String, IconData> _iconMap = {
    'sensors': Icons.sensors,
    'thermostat': Icons.thermostat,
    'light': Icons.lightbulb,
    'camera': Icons.videocam,
    'fan': Icons.toys,
  };

  static IconData? _iconFromName(String? name) {
    if (name == null) return null;
    return _iconMap[name];
  }

  static String? _nameFromIcon(IconData icon) {
    return _iconMap.entries
        .firstWhere((entry) => entry.value == icon, orElse: () => const MapEntry('sensors', Icons.sensors))
        .key;
  }
}
