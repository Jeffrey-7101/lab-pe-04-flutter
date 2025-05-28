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
    required this.bgColor,
    required this.icon,
    required this.iconColor,
    required this.deviceTextColor,
  });
}
