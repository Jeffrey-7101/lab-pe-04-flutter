import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/device_viewmodel.dart';
import '../widgets/user_profile_icon.dart';
import '../monitoring/monitoring_screen.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DevicesViewModel>();
    final devices = vm.devices;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Dispositivos'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: UserProfileIcon(
              size: 36.0,
              backgroundColor: Colors.green.shade100,
              iconColor: Colors.green.shade700,              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ),
        ],
      ),
      body: devices.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: devices.length,
              itemBuilder: (context, i) {
                final d = devices[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MonitoringScreen(deviceId: d.id),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(
                        d.icon,
                        color: d.isOnline ? Colors.green.shade700 : Colors.red.shade700,
                        size: 32,
                      ),
                      title: Text(
                        d.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Última actualización: ${d.lastSeen}'),
                      trailing: Text(
                        d.isOnline ? 'En línea' : 'Desconectado',
                        style: TextStyle(
                          color: d.isOnline ? Colors.green.shade700 : Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
