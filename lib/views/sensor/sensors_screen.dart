import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/device_viewmodel.dart';
import '../../models/device_item.dart';
import '../../models/sensor.dart';
import '../widgets/bottom_navbar.dart'; // Asegúrate de importar correctamente
import '../dashboard/dashboard_screen.dart';
import '../notifications/notifications_screen.dart';

class SensorsScreen extends StatelessWidget {
  final String deviceId;

  const SensorsScreen({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final device = Provider.of<DevicesViewModel>(context).getDeviceById(deviceId);

    if (device == null) {
      return const Scaffold(
        body: Center(child: Text("Dispositivo no encontrado")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Sensores: ${device.name}")),
      body: ListView.builder(
        itemCount: device.sensors.length,
        itemBuilder: (context, index) {
          final sensor = device.sensors[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(sensor.type == SensorType.humidity
                  ? "Sensor Humedad"
                  : "Sensor Temperatura"),
              subtitle: Text("Valor actual: ${sensor.value} - Estado: ${sensor.status}"),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          );
        },
      ),

      /// 👇 Aquí está el BottomNavBar que pediste
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0, // Estás en la pestaña de Dispositivos
        onTap: (idx) {
          switch (idx) {
            case 0:
              // Ya estás aquí, no haces nada
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
