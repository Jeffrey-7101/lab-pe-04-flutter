import 'package:flutter/material.dart';
import '../sensor/sensors_screen.dart';
// import '../monitor/monitor_screen.dart';

class DeviceTopNavigation extends StatelessWidget {
  final String deviceId;
  final int selectedIndex;

  const DeviceTopNavigation({
    super.key,
    required this.deviceId,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Título del dispositivo (puedes hacerlo dinámico si quieres)
        const SizedBox(height: 12),
        TabBar(
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.green,
          onTap: (index) {
            if (index == 0 && selectedIndex != 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => SensorsScreen(deviceId: deviceId),
                ),
              );
            } else if (index == 1 && selectedIndex != 1) {
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(
              //     builder: (_) => MonitorScreen(deviceId: deviceId),
              //   ),
              // );
            }
          },
          tabs: const [
            Tab(text: 'Sensores'),
            Tab(text: 'Monitor'),
          ],
        ),
      ],
    );
  }
}
