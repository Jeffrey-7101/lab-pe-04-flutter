import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/notifications_viewmodel.dart';
import '../widgets/profile_app_bar_action.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationsViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,        actions: [
          const ProfileAppBarAction(),
        ],
      ),
      body: vm.notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: vm.notifications.length,
              itemBuilder: (context, i) {
                final item = vm.notifications[i];
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              },
            ),
    );
  }
}
