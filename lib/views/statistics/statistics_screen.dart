import 'package:flutter/material.dart';
import '../devices/device_screen.dart';
import '../widgets/bottom_navbar.dart';
import '../notifications/notifications_screen.dart';
import 'sensor_chart_screen.dart';
import '../../models/sensor.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _metrics = [
    _Metric(label: 'Temp. Actual', value: '24°C', icon: Icons.thermostat_outlined, type: SensorType.temperature),
    _Metric(label: 'Humedad', value: '65%', icon: Icons.water_drop_outlined, type: SensorType.humidity),
    _Metric(label: 'Luz', value: '750 lx', icon: Icons.wb_sunny_outlined, type: SensorType.light),
    _Metric(label: 'CO₂', value: '400 ppm', icon: Icons.cloud_outlined, type: SensorType.co2),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Estadísticas'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SensorChartScreen(
                      sensorType: SensorType.temperature,
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '📈 Gráfico de Temperatura',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Toca para ver en tiempo real',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _metrics.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, i) {
                final m = _metrics[i];
                return _MetricCard(metric: m);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (idx) {
          switch (idx) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DevicesScreen()),
              );
              break;
            case 1:
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

class _Metric {
  final String label;
  final String value;
  final IconData icon;
  final SensorType type;
  const _Metric({
    required this.label,
    required this.value,
    required this.icon,
    required this.type,
  });
}

class _MetricCard extends StatelessWidget {
  final _Metric metric;
  const _MetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: () {        Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (_) => SensorChartScreen(
      //         sensorType: metric.type,
      //       ),
      //     ),
      //   );
      // },
      child: Card(
        color: Colors.white.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(metric.icon, size: 32, color: Colors.green.shade700),
              const Spacer(),
              Text(
                metric.value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(metric.label),
              const SizedBox(height: 4),
              const Text(
                'Toca para ver en tiempo real',
                style: TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}