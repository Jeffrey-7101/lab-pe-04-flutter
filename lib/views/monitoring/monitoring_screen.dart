import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/device_viewmodel.dart';
import '../../core/routes/navigation_helper.dart';
import '../../models/sensor.dart';

class MonitoringScreen extends StatefulWidget {
  final String deviceId;

  const MonitoringScreen({super.key, required this.deviceId});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DevicesViewModel>();
    final device = vm.getDeviceById(widget.deviceId);

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
              // Header con botón de regreso y título
              _buildHeader(device.name),
              
              // Tab Bar personalizado
              _buildTabBar(),
                // Contenido de los tabs
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(), // Sin animación al deslizar
                  children: [
                    _MonitoringTab(device: device, deviceId: widget.deviceId),
                    _SensorsTab(device: device, deviceId: widget.deviceId),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String deviceName) {
    return Padding(
      padding: const EdgeInsets.all(12.0), // Reducido de 16 a 12
      child: Row(
        children: [
          IconButton(
            onPressed: () => NavigationHelper.goBack(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deviceName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22, // Reducido de 24 a 22
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Monitoreo en tiempo real',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.analytics, size: 32, color: Colors.white),
        ],
      ),
    );
  }
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32), // Más estrecho
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        indicatorSize: TabBarIndicatorSize.tab, // Indicador ocupa todo el tab
        labelColor: Colors.green.shade700,
        unselectedLabelColor: Colors.white,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        tabs: const [
          Tab(text: 'Monitor'),
          Tab(text: 'Sensores'),
        ],
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
  final String deviceId;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.sensorType,
    required this.deviceId,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.9),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          NavigationHelper.toSensorChart(
            context,
            sensorType: sensorType,
            deviceId: deviceId,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12), // Reducido de 16 a 12
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: color), // Reducido de 32 a 28
              const SizedBox(height: 6), // Reducido de 8 a 6
              Text(
                value,
                style: TextStyle(
                  fontSize: 18, // Reducido de 20 a 18
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11, // Reducido de 12 a 11
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget para mostrar un switch/interruptor
class _SwitchCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final SensorType sensorType;
  final String deviceId;
  final bool isActive;

  const _SwitchCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.sensorType,
    required this.deviceId,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DevicesViewModel>();
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(12), // Reducido de 16 a 12
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: isActive ? color : Colors.grey), // Reducido de 32 a 28
            const SizedBox(height: 6), // Reducido de 8 a 6
            Text(
              label,
              style: const TextStyle(
                fontSize: 12, // Reducido de 14 a 12
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8), // Reducido de 12 a 8
            Switch(
              value: isActive,
              onChanged: (value) {
                vm.updateSensorActiveState(deviceId, sensorType, value);
              },
              activeColor: color,
              activeTrackColor: color.withOpacity(0.3),
            ),
            const SizedBox(height: 2), // Reducido de 4 a 2
            Text(
              isActive ? 'Activado' : 'Desactivado',
              style: TextStyle(
                fontSize: 10, // Reducido de 12 a 10
                color: isActive ? color : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tab de Monitoreo - Vista principal con métricas
class _MonitoringTab extends StatelessWidget {
  final dynamic device;
  final String deviceId;

  const _MonitoringTab({
    required this.device,
    required this.deviceId,
  });

  @override
  Widget build(BuildContext context) {
    // Buscar sensores específicos
    final tempSensor = device.sensors.cast<Sensor?>().firstWhere(
      (s) => s?.type == SensorType.temperature,
      orElse: () => null,
    );
    
    final humSensor = device.sensors.cast<Sensor?>().firstWhere(
      (s) => s?.type == SensorType.humidity,
      orElse: () => null,
    );    return SingleChildScrollView(
      padding: const EdgeInsets.all(12), // Reducido de 16 a 12
      child: Column(
        children: [
          // Header del tab con icono
          Row(
            children: [
              Icon(
                Icons.monitor,
                color: Colors.white,
                size: 22, // Reducido de 24 a 22
              ),
              const SizedBox(width: 8),
              const Text(
                'Panel de Control',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16, // Reducido de 18 a 16
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Reducido de 16 a 12
          
          // Estado del dispositivo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16), // Reducido de 20 a 16
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  device.isOnline ? Icons.check_circle : Icons.error,
                  size: 42, // Reducido de 48 a 42
                  color: device.isOnline ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 6), // Reducido de 8 a 6
                Text(
                  device.isOnline ? 'En línea' : 'Desconectado',
                  style: TextStyle(
                    fontSize: 16, // Reducido de 18 a 16
                    fontWeight: FontWeight.bold,
                    color: device.isOnline ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Última actualización: ${device.lastSeen}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16), // Reducido de 20 a 16
          
          // Grid de métricas principales
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12, // Reducido de 16 a 12
            mainAxisSpacing: 12, // Reducido de 16 a 12
            childAspectRatio: 0.85, // Hacer las cards más compactas
            children: [
              _MetricCard(
                label: 'Temperatura',
                value: tempSensor?.getFormattedValue() ?? '--',
                icon: Icons.thermostat_outlined,
                color: Colors.red,
                sensorType: SensorType.temperature,
                deviceId: deviceId,
              ),
              _MetricCard(
                label: 'Humedad',
                value: humSensor?.getFormattedValue() ?? '--',
                icon: Icons.water_drop_outlined,
                color: Colors.blue,
                sensorType: SensorType.humidity,
                deviceId: deviceId,
              ),
              _SwitchCard(
                label: 'Control de Temperatura',
                icon: Icons.device_thermostat,
                color: Colors.red,
                sensorType: SensorType.temperature,
                deviceId: deviceId,
                isActive: tempSensor?.actionIsActive ?? false,
              ),
              _SwitchCard(
                label: 'Control de Humedad',
                icon: Icons.opacity,
                color: Colors.blue,
                sensorType: SensorType.humidity,
                deviceId: deviceId,
                isActive: humSensor?.actionIsActive ?? false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tab de Sensores - Lista detallada de todos los sensores
class _SensorsTab extends StatelessWidget {
  final dynamic device;
  final String deviceId;

  const _SensorsTab({
    required this.device,
    required this.deviceId,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header del tab con icono
        Padding(
          padding: const EdgeInsets.all(12), // Reducido de 16 a 12
          child: Row(
            children: [
              Icon(
                Icons.sensors,
                color: Colors.white,
                size: 22, // Reducido para consistencia
              ),
              const SizedBox(width: 8),
              const Text(
                'Lista de Sensores',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16, // Reducido para consistencia
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // Lista de sensores
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12), // Reducido de 16 a 12
            itemCount: device.sensors.length,
            itemBuilder: (context, index) {
              final sensor = device.sensors[index];
              return _SensorListItem(
                sensor: sensor,
                deviceId: deviceId,
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Widget para mostrar un sensor en la lista
class _SensorListItem extends StatelessWidget {
  final Sensor sensor;
  final String deviceId;

  const _SensorListItem({
    required this.sensor,
    required this.deviceId,
  });
  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color color;

    switch (sensor.type) {
      case SensorType.temperature:
        icon = Icons.thermostat_outlined;
        color = Colors.red;
        break;
      case SensorType.humidity:
        icon = Icons.water_drop_outlined;
        color = Colors.blue;
        break;
      case SensorType.light:
        icon = Icons.wb_sunny_outlined;
        color = Colors.orange;
        break;
      case SensorType.co2:
        icon = Icons.cloud_outlined;
        color = Colors.grey;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8), // Reducido de 12 a 8
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // Padding más compacto
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color, size: 20), // Ícono más pequeño
        ),
        title: Text(
          sensor.getLabel(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${sensor.getFormattedValue()} • Estado: ${sensor.status}'),
        trailing: IconButton(
          icon: const Icon(Icons.show_chart),
          onPressed: () {
            NavigationHelper.toSensorChart(
              context,
              sensorType: sensor.type,
              deviceId: deviceId,
            );
          },
        ),
        onTap: () {
          // Solo para temperatura y humedad navegar a pantallas de configuración
          if (sensor.type == SensorType.temperature || sensor.type == SensorType.humidity) {
            NavigationHelper.toSensorConfig(
              context,
              sensorType: sensor.type,
              deviceId: deviceId,
            );
          } else {
            // Para otros sensores, mantener el comportamiento anterior
            NavigationHelper.toSensorChart(
              context,
              sensorType: sensor.type,
              deviceId: deviceId,
            );
          }
        },
      ),
    );
  }
}
