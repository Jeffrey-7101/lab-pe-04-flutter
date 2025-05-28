import 'package:flutter/material.dart';
import '../models/notification_item.dart';

class NotificationsViewModel extends ChangeNotifier {
  List<NotificationItem> _notifications = [];
  List<NotificationItem> get notifications => _notifications;

  NotificationsViewModel() {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    await Future.delayed(const Duration(seconds: 1));
    _notifications = [
      const NotificationItem(
        deviceName: 'Dispositivo 1',
        message: 'Sensor 1 temperatura muy baja',
        timeAgo: 'hace 1 h',
        bgColor: Color(0xFFA6D8FF),
        icon: Icons.thermostat_outlined,
        iconColor: Colors.black,
        deviceTextColor: Colors.brown,
      ),
      
      const NotificationItem(
        deviceName: 'Dispositivo 2',
        message: 'Sensor 1 temperatura muy alta',
        timeAgo: 'hace 23 m',
        bgColor: Color(0xFFFFA6A6),
        icon: Icons.thermostat_outlined,
        iconColor: Colors.black,
        deviceTextColor: Colors.cyan,
      ),

      const NotificationItem(
        deviceName: 'Dispositivo 3',
        message: 'Sensor 2 demasiada humedad',
        timeAgo: 'hace 1 d',
        bgColor: Color(0xFF5772FF),
        icon: Icons.water_drop_outlined,
        iconColor: Colors.black,
        deviceTextColor: Colors.lightGreen,
      ),

      const NotificationItem(
        deviceName: 'Dispositivo 4',
        message: 'Sensor 1 poca humedad',
        timeAgo: 'hace 56 s',
        bgColor: Color(0xFFD6CFC7),
        icon: Icons.water_drop_outlined,
        iconColor: Colors.black,
        deviceTextColor: Colors.blue,
      ),
    ];
    notifyListeners();
  }
}
