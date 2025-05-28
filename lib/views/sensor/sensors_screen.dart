import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/device_viewmodel.dart';
import '../../models/sensor.dart';
import '../widgets/bottom_navbar.dart';
import '../statistics/statistics_screen.dart';
import '../notifications/notifications_screen.dart';
import '../widgets/view_switcher.dart';
import '../monitoring/monitoring_screen.dart';

class SensorsScreen extends StatelessWidget {
  final String deviceId;

  const SensorsScreen({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final device = context.watch<DevicesViewModel>().getDeviceById(deviceId);

    if (device == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Dispositivo no encontrado",
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFa8e063), Color(0xFF56ab2f)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
               ViewSwitcher(
                isMonitoring: false,
                onMonitoringTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MonitoringScreen(deviceId: deviceId),
                    ),
                  );
                },
                onSensorsTap: (){
                  //ya no hace nada
                }
               ),
              const Icon(
                Icons.sensors,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                device.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sensores conectados',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: ListView.builder(
                    itemCount: device.sensors.length,
                    itemBuilder: (context, index) {
                      final sensor = device.sensors[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: sensor.type == SensorType.humidity
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                            child: Icon(
                              sensor.type == SensorType.humidity
                                  ? Icons.water_drop_outlined
                                  : Icons.thermostat_outlined,
                              color: sensor.type == SensorType.humidity
                                  ? Colors.blue
                                  : Colors.red,
                            ),
                          ),
                          title: Text(
                            sensor.type == SensorType.humidity
                                ? 'Humedad'
                                : 'Temperatura',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(
                              'Valor: ${sensor.value} ${sensor.type}'),
                          trailing: Text(
                            sensor.status,
                            style: TextStyle(
                              color: sensor.status == 'OK'
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (idx) {
          switch (idx) {
            case 0:
              // Ya estamos aquí
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
              break;
          }
        },
      ),
    );
  }
}
