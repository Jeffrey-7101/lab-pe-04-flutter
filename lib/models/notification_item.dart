import 'package:flutter/material.dart';

class NotificationItem {
  final String deviceName;
  final String message;
  final String severity;
  final DateTime timestamp;
  final Color bgColor;
  final IconData icon;
  final Color iconColor;
  final Color deviceTextColor;

  NotificationItem({
    required this.deviceName,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.bgColor = const Color(0xFFE0F7FA),
    this.icon = Icons.sensors,
    this.iconColor = Colors.lightGreen,
    this.deviceTextColor = Colors.blueGrey,
  });

  String get timeAgo {
    final now = DateTime.now().toUtc();
    final diff = now.difference(timestamp);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  factory NotificationItem.fromJson(Map<dynamic, dynamic> json) {
    return NotificationItem(
      deviceName: json['deviceName'] ?? '',
      message: json['message'] ?? '',
      severity: json['severity'] ?? 'normal',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() => {
        'deviceName': deviceName,
        'message': message,
        'severity': severity,
        'timestamp': timestamp.toIso8601String(),
        'bgColor': bgColor.value,
        'icon': icon.codePoint,
        'iconColor': iconColor.value,
        'deviceTextColor': deviceTextColor.value,
      };
}
