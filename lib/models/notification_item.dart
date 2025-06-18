import 'package:flutter/material.dart';

class NotificationItem {
  final String deviceName;
  final String message;
  final String timeAgo;
  final Color bgColor;
  final IconData icon;
  final Color iconColor;
  final Color deviceTextColor;

  const NotificationItem({
    required this.deviceName,
    required this.message,
    required this.timeAgo,

    this.bgColor = const Color(0xFFE0F7FA),
    this.icon = Icons.sensors,
    this.iconColor = Colors.lightGreen,
    this.deviceTextColor = Colors.blueGrey,
  });

  factory NotificationItem.fromJson(Map<dynamic, dynamic> json) {
    return NotificationItem(
      deviceName: json['deviceName'] as String? ?? '',
      message:    json['message']    as String? ?? '',
      timeAgo:    json['timeAgo']    as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'deviceName': deviceName,
        'message':    message,
        'timeAgo':    timeAgo,
        'bgColor':    bgColor.value,
        'icon':       icon.codePoint,
        'iconColor':  iconColor.value,
        'deviceTextColor': deviceTextColor.value,
      };

  static Color _colorFrom(dynamic v) {
    final intVal = v is int
        ? v
        : int.tryParse(v.toString()) ?? 0xFFFFFFFF;
    return Color(intVal);
  }

  static IconData _iconFrom(dynamic v) {
    final cp = v is int
        ? v
        : int.tryParse(v.toString());
    return cp == null
        ? Icons.sensors
        : IconData(cp, fontFamily: 'MaterialIcons');
  }
}
