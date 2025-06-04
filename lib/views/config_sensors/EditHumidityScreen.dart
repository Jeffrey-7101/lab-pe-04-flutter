import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/device_viewmodel.dart';
import '../../models/sensor.dart';

class EditHumidityScreen extends StatefulWidget {
  final String deviceId;

  const EditHumidityScreen({super.key, required this.deviceId});

  @override
  State<EditHumidityScreen> createState() => _EditHumidityScreenState();
}

class _EditHumidityScreenState extends State<EditHumidityScreen> {
  late double minValue;
  late double maxValue;

  @override
  void initState() {
    super.initState();
    final device = Provider.of<DevicesViewModel>(
      context,
      listen: false,
    ).getDeviceById(widget.deviceId);
    final sensor = device?.sensors.firstWhere(
      (s) => s.type == SensorType.humidity,
      orElse: () => Sensor(
        type: SensorType.humidity,
        value: 0,
        minValue: 0,
        maxValue: 100,
      ),
    );

    minValue = sensor?.minValue ?? 0;
    maxValue = sensor?.maxValue ?? 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Humedad")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              initialValue: minValue.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Humedad Mínima'),
              onChanged: (val) => minValue = double.tryParse(val) ?? minValue,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: maxValue.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Humedad Máxima'),
              onChanged: (val) => maxValue = double.tryParse(val) ?? maxValue,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                final vm = Provider.of<DevicesViewModel>(
                  context,
                  listen: false,
                );
                vm.updateSensorLimits(
                  widget.deviceId,
                  SensorType.humidity,
                  minValue,
                  maxValue,
                );
                Navigator.pop(context); // Volver atrás
              },
              child: const Text("Guardar Cambios"),
            ),
          ],
        ),
      ),
    );
  }
}
