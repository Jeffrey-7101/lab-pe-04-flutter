import 'package:flutter/material.dart';
import 'sensor.dart';

class DeviceItem {
  final String id;
  final String name;
  final bool isOnline;
  final String lastSeen;
  final IconData? icon;
  final List<Sensor> sensors;

  const DeviceItem({
    required this.id,
    required this.name,
    required this.isOnline,
    required this.lastSeen,
    this.icon,
    this.sensors = const [],
  });

  factory DeviceItem.fromJson(
    String id,
    Map<dynamic, dynamic> json,
  ) {
    final sensorsMap = json['sensors'] as Map<dynamic, dynamic>? ?? {};

    return DeviceItem(
      id: id,
      name: json['name'] as String? ?? '',
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: json['lastSeen'] as String? ?? '',
      icon: _iconFromString(json['icon'] as String?),
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
        'icon': icon?.codePoint.toString(),
        'sensors': {
          for (var s in sensors) s.type.name: s.toJson(),
        },
      };

  static IconData? _iconFromString(String? codePointStr) {
    if (codePointStr == null) return null;
    final cp = int.tryParse(codePointStr);
    return cp == null ? null : IconData(cp, fontFamily: 'MaterialIcons');
  }
}
