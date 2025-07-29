import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/device_viewmodel.dart';
import '../../core/routes/navigation_helper.dart';
import '../widgets/profile_app_bar_action.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DevicesViewModel>();
    final devices = vm.devices;
    final primaryGreen = const Color(0xFF56ab2f);
    final secondaryGreen = const Color(0xFFa8e063);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Dispositivos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: const [ProfileAppBarAction()],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [secondaryGreen, primaryGreen],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: devices.isEmpty
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: devices.length,
                  itemBuilder: (context, i) {
                    final d = devices[i];
                    final onlineColor = d.isOnline ? primaryGreen : Colors.red.shade700;

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => NavigationHelper.toMonitoring(context, d.id),
                      child: Card(
                        color: Colors.white.withOpacity(0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Icon(
                            d.icon,
                            color: onlineColor,
                            size: 32,
                          ),
                          title: Text(
                            d.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryGreen,
                            ),
                          ),
                          subtitle: Text(
                            'Última actualización: ${d.lastSeen}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                          trailing: Text(
                            d.isOnline ? 'En línea' : 'Desconectado',
                            style: TextStyle(
                              color: onlineColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
