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
}
