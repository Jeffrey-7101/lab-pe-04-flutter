import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/notifications_viewmodel.dart';
import '../widgets/profile_app_bar_action.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationsViewModel>();
    // Tus tonos verde característicos:
    const primaryGreen = Color(0xFF56ab2f);
    const secondaryGreen = Color(0xFFa8e063);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Notificaciones',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: const [ProfileAppBarAction()],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [secondaryGreen, primaryGreen],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: vm.notifications.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: vm.notifications.length,
                  itemBuilder: (context, i) {
                    final item = vm.notifications[i];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          // Icono dentro de círculo semitransparente
                          Container(
                            decoration: BoxDecoration(
                              color: item.iconColor.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Icon(item.icon,
                                size: 32, color: item.iconColor),
                          ),
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
                                    color: primaryGreen,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.message,
                                  style: const TextStyle(
                                      color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            item.timeAgo,
                            style: TextStyle(
                              color: primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
