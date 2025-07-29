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
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () =>
                                NavigationHelper.goBack(context),
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white, size: 28),
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
                          const Icon(Icons.bar_chart,
                              color: Colors.white, size: 28),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: vm.selectedDevice,
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: Colors.black54),
                            items: vm.deviceIds
                                .map((d) => DropdownMenuItem(
                                      value: d,
                                      child: Text(
                                        d.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (d) {
                              if (d != null) vm.selectDevice(d);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        height: 48,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: vm.granularities.map((g) {
                              final isSelected =
                                  vm.selectedGranularity == g;
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: SizedBox(
                                  width: 80,
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        vm.selectGranularity(g),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isSelected
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        side: BorderSide(
                                          color: isSelected
                                              ? Colors.green
                                              : Colors.green.withOpacity(0.5),
                                        ),
                                      ),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                    ),
                                    child: Text(
                                      g.label,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.green.shade800
                                            : Colors.white,
                                        fontSize: 14,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
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

                      Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Humedad',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                            const SizedBox(width: 8),
                            Transform.scale(
                              scale: 1.1,
                              child: Switch(
                                value: vm.selectedSensor ==
                                    SensorType.temperature,
                                onChanged: (v) {
                                  vm.selectSensor(v
                                      ? SensorType.temperature
                                      : SensorType.humidity);
                                },
                                activeColor: Colors.white,
                                activeTrackColor: Colors.white54,
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: Colors.white54,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Temperatura',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Expanded(
                        child: vm.statistics.isEmpty
                            ? const Center(
                                child: Text(
                                  'Cargando datos...',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 16),
                                ),
                              )
                            : ListView(
                                children: [
                                  // Tarjeta último registro
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    color: Colors.white.withOpacity(0.9),
                                    margin:
                                        const EdgeInsets.only(bottom: 20),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Último periodo: ${vm.statistics.last.periodStart}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Min: ${vm.statistics.last.minValue}',
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                          Text(
                                            'Max: ${vm.statistics.last.maxValue}',
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                          Text(
                                            'Mean: ${vm.statistics.last.meanValue}',
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                          Text(
                                            'Count: ${vm.statistics.last.countValue}',
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // LineChart meanValue
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    color: Colors.white.withOpacity(0.9),
                                    margin:
                                        const EdgeInsets.only(bottom: 20),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: SizedBox(
                                        height: 180,
                                        child: LineChart(
                                          LineChartData(
                                            gridData:
                                                FlGridData(show: false),
                                            titlesData:
                                                FlTitlesData(show: false),
                                            borderData:
                                                FlBorderData(show: false),
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: vm.statistics
                                                    .map((s) =>
                                                        FlSpot(
                                                            s.periodStart
                                                                .millisecondsSinceEpoch
                                                                .toDouble(),
                                                            s.meanValue))
                                                    .toList(),
                                                isCurved: true,
                                                dotData:
                                                    FlDotData(show: false),
                                                color:
                                                    Colors.green.shade800,
                                                barWidth: 3,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // BarChart countValue
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    color: Colors.white.withOpacity(0.9),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: SizedBox(
                                        height: 180,
                                        child: BarChart(
                                          BarChartData(
                                            gridData:
                                                FlGridData(show: false),
                                            titlesData:
                                                FlTitlesData(show: false),
                                            borderData:
                                                FlBorderData(show: false),
                                            barGroups: vm.statistics
                                                .asMap()
                                                .entries
                                                .map((e) {
                                              return BarChartGroupData(
                                                x: e.key,
                                                barRods: [
                                                  BarChartRodData(
                                                    toY: e.value.countValue,
                                                    color: Colors
                                                        .green.shade800,
                                                    width: 14,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
