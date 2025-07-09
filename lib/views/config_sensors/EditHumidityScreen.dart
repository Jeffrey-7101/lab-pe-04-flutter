import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';

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
  late final DatabaseReference _sensorRef;

  @override
  void initState() {
    super.initState();
    // 1) Cargo los valores iniciales desde el ViewModel
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

    // 2) Apunto al nodo de humedad en Firebase
    final sensorId = '${widget.deviceId}_${SensorType.humidity.name}';
    _sensorRef = FirebaseDatabase.instance.ref('sensors/$sensorId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Editar Humedad'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.water_drop_outlined,
                    size: 80, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'Configuración de Humedad',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ajusta los valores mínimo y máximo para este sensor',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      _buildInputField(
                        initialValue: minValue.toString(),
                        hint: 'Humedad Mínima',
                        icon: Icons.arrow_downward,
                        onChanged: (val) =>
                            minValue = double.tryParse(val) ?? minValue,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        initialValue: maxValue.toString(),
                        hint: 'Humedad Máxima',
                        icon: Icons.arrow_upward,
                        onChanged: (val) =>
                            maxValue = double.tryParse(val) ?? maxValue,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 64, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () async {
                          // Escribo en Firebase y luego actualizo el ViewModel
                          try {
                            // 1) Update en Realtime Database
                            await _sensorRef.update({
                              'minValue': minValue,
                              'maxValue': maxValue,
                            });

                            // 2) Actualizo también en el VM para mantener UI coherente
                            final vm = Provider.of<DevicesViewModel>(
                              context,
                              listen: false,
                            );
                            await vm.updateSensorLimits(
                              widget.deviceId,
                              SensorType.humidity,
                              minValue,
                              maxValue,
                            );

                            // 3) Confirmación
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Configuración de humedad actualizada',
                                ),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error al guardar: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Guardar Cambios',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String initialValue,
    required String hint,
    required IconData icon,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.green.shade700),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: onChanged,
    );
  }
}
