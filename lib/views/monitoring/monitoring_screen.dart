import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/device_viewmodel.dart';
import '../widgets/bottom_navbar.dart';
import '../statistics/statistics_screen.dart';
import '../notifications/notifications_screen.dart';
import '../devices/device_screen.dart';
import '../widgets/view_switcher.dart';
import '../sensor/sensors_screen.dart';
import '../statistics/sensor_chart_screen.dart';
import '../../models/sensor.dart';

class MonitoringScreen extends StatelessWidget {
  final String deviceId;

  const MonitoringScreen({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DevicesViewModel>();
    final device = vm.getDeviceById(deviceId);

    final tempIndex = device.sensors.indexWhere(
      (s) => s.type == SensorType.temperature,
    );
    Sensor? tempSensor = tempIndex != -1 
        ? device.sensors[tempIndex] 
        : null;

    final humIndex = device.sensors.indexWhere(
      (s) => s.type == SensorType.humidity,
    );
    Sensor? humSensor = humIndex != -1 
        ? device.sensors[humIndex] 
        : null;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
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
                isMonitoring: true,
                onMonitoringTap: () {/* ya estamos aquí */},
                onSensorsTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SensorsScreen(deviceId: deviceId),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              const Icon(Icons.analytics, size: 80, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                device.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SensorChartScreen(
                        sensorType: SensorType.temperature,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      '📈 Gráfico en tiempo real',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _MetricCard(
                      label: 'Temperatura',
                      // Si existe el sensor, formatea; si no, muestra guiones
                      value: tempSensor?.getFormattedValue() ?? '--',
                      icon: Icons.thermostat_outlined,
                      color: Colors.red,
                      sensorType: SensorType.temperature,
                    ),
                    const SizedBox(width: 16),
                    _MetricCard(
                      label: 'Humedad',
                      value: humSensor?.getFormattedValue() ?? '--',
                      icon: Icons.water_drop_outlined,
                      color: Colors.blue,
                      sensorType: SensorType.humidity,
                    ),
                  ],
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DevicesScreen()),
              );
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

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final SensorType sensorType;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.sensorType,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SensorChartScreen(sensorType: sensorType),
            ),
          );
        },
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white.withOpacity(0.9),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(icon, size: 32, color: color),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
