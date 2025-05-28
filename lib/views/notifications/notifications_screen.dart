import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';
import '../dashboard/dashboard_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static final List<_NotificationItem> _items = [
    _NotificationItem(
      deviceName: 'Dispositivo 1',
      message: 'Sensor 1 temperatura muy baja',
      timeAgo: 'hace 1 h',
      bgColor: const Color(0xFFA6D8FF),
      icon: Icons.thermostat_outlined,
      iconColor: Colors.black,
      deviceTextColor: Colors.brown,
    ),
    _NotificationItem(
      deviceName: 'Dispositivo 2',
      message: 'Sensor 1 temperatura muy alta',
      timeAgo: 'hace 23 m',
      bgColor: const Color(0xFFFFA6A6),
      icon: Icons.thermostat_outlined,
      iconColor: Colors.black,
      deviceTextColor: Colors.cyan,
    ),
    _NotificationItem(
      deviceName: 'Dispositivo 3',
      message: 'Sensor 2 demasiada humedad',
      timeAgo: 'hace 1 d',
      bgColor: const Color(0xFF5772FF),
      icon: Icons.water_drop_outlined,
      iconColor: Colors.black,
      deviceTextColor: Colors.lightGreen,
    ),
    _NotificationItem(
      deviceName: 'Dispositivo 4',
      message: 'Sensor 1 poca humedad',
      timeAgo: 'hace 56 s',
      bgColor: const Color(0xFFD6CFC7),
      icon: Icons.water_drop_outlined,
      iconColor: Colors.black,
      deviceTextColor: Colors.blue,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: _items.length,
        itemBuilder: (context, i) => _NotificationTile(item: _items[i]),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (idx) {
          switch (idx) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
              break;
            case 2:
              // ya estamos aquí
              break;
          }
        },
      ),
    );
  }
}

class _NotificationItem {
  final String deviceName;
  final String message;
  final String timeAgo;
  final Color bgColor;
  final IconData icon;
  final Color iconColor;
  final Color deviceTextColor;

  const _NotificationItem({
    required this.deviceName,
    required this.message,
    required this.timeAgo,
    required this.bgColor,
    required this.icon,
    required this.iconColor,
    required this.deviceTextColor,
  });
}

class _NotificationTile extends StatelessWidget {
  final _NotificationItem item;
  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(item.icon, size: 32, color: item.iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.deviceName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: item.deviceTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(item.message),
              ],
            ),
          ),
          Text(
            item.timeAgo,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }
}
