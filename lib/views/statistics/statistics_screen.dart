import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../viewmodels/statistics_viewmodel.dart';
import '../../models/statistic.dart';
import '../../models/sensor.dart';
import '../../core/routes/navigation_helper.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StatisticsViewModel(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFa8e063), Color(0xFF56ab2f)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Consumer<StatisticsViewModel>(
              builder: (context, vm, child) {
                final stats = vm.statistics;
                final hasData = stats.isNotEmpty;
                final last = hasData ? stats.last : null;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => NavigationHelper.goBack(context),
                            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Estadísticas',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(Icons.bar_chart, color: Colors.white, size: 28),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Dispositivo selector
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: vm.selectedDevice,
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                            items: vm.deviceIds
                                .map((d) => DropdownMenuItem(
                                      value: d,
                                      child: Text(d.toUpperCase(),
                                          style: const TextStyle(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w600)),
                                    ))
                                .toList(),
                            onChanged: (d) => d != null ? vm.selectDevice(d) : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Granularidad carrusel
                      SizedBox(
                        height: 48,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: vm.granularities.map((g) {
                              final sel = vm.selectedGranularity == g;
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: SizedBox(
                                  width: 80,
                                  child: ElevatedButton(
                                    onPressed: () => vm.selectGranularity(g),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          sel ? Colors.white : Colors.white.withOpacity(0.3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(
                                          color: sel
                                              ? Colors.green
                                              : Colors.green.withOpacity(0.5),
                                        ),
                                      ),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                    ),
                                    child: Text(
                                      g.label,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: sel ? Colors.green.shade800 : Colors.white,
                                        fontSize: 14,
                                        fontWeight: sel ? FontWeight.bold : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Switch sensor
                      Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Humedad',
                                style: TextStyle(color: Colors.white, fontSize: 16)),
                            const SizedBox(width: 8),
                            Transform.scale(
                              scale: 1.1,
                              child: Switch(
                                value: vm.selectedSensor == SensorType.temperature,
                                onChanged: (v) => vm.selectSensor(
                                    v ? SensorType.temperature : SensorType.humidity),
                                activeColor: Colors.white,
                                activeTrackColor: Colors.white54,
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: Colors.white54,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Temperatura',
                                style: TextStyle(color: Colors.white, fontSize: 16)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Datos o carga
                      hasData
                          ? Expanded(
                              child: ListView(
                                children: [
                                  // Grid de 4 tarjetas
                                  GridView.count(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    childAspectRatio: 1.2,
                                    children: [
                                      _StatCard(
                                        label: 'Mínimo',
                                        value: last!.minValue.toStringAsFixed(1),
                                        icon: Icons.arrow_downward,
                                        color: Colors.blueAccent,
                                      ),
                                      _StatCard(
                                        label: 'Máximo',
                                        value: last.maxValue.toStringAsFixed(1),
                                        icon: Icons.arrow_upward,
                                        color: Colors.redAccent,
                                      ),
                                      _StatCard(
                                        label: 'Media',
                                        value: last.meanValue.toStringAsFixed(1),
                                        icon: Icons.show_chart,
                                        color: Colors.orangeAccent,
                                      ),
                                      _StatCard(
                                        label: 'Registros',
                                        value: last.countValue.toStringAsFixed(0),
                                        icon: Icons.format_list_numbered,
                                        color: Colors.greenAccent,
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // Línea de tendencia
                                  Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)),
                                    color: Colors.white.withOpacity(0.9),
                                    margin: const EdgeInsets.only(bottom: 20),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: SizedBox(
                                        height: 180,
                                        child: LineChart(
                                          LineChartData(
                                            gridData: FlGridData(show: true),
                                            titlesData: FlTitlesData(show: false),
                                            borderData: FlBorderData(show: false),
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: stats
                                                    .map((s) => FlSpot(
                                                        s.periodStart
                                                            .millisecondsSinceEpoch
                                                            .toDouble(),
                                                        s.meanValue))
                                                    .toList(),
                                                isCurved: true,
                                                dotData: FlDotData(show: false),
                                                color: Colors.green.shade800,
                                                barWidth: 3,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const Expanded(
                              child: Center(
                                  child: Text('Cargando datos...',
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 16))),
                            ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta genérica para mostrar un valor estadístico
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
