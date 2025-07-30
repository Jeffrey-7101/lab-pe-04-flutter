import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../models/sensor.dart';
import '../../viewmodels/sensor_chart_viewmodel.dart';
import '../../viewmodels/device_viewmodel.dart';
import '../../core/routes/navigation_helper.dart';
import '../widgets/profile_app_bar_action.dart';

class SensorChartScreen extends StatelessWidget {
  final String? deviceId;
  final SensorType sensorType;

  const SensorChartScreen({
    Key? key,
    this.deviceId,
    required this.sensorType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vmDevices = context.read<DevicesViewModel>();
    final actualDeviceId = deviceId ??
        (vmDevices.devices.isNotEmpty ? vmDevices.devices.first.id : '');

    return ChangeNotifierProvider(
      create: (_) => SensorChartViewModel(
        deviceId: actualDeviceId,
        sensorType: sensorType,
      ),
      child: _SensorChartView(sensorType: sensorType),
    );
  }
}

class _SensorChartView extends StatelessWidget {
  final SensorType sensorType;

  const _SensorChartView({Key? key, required this.sensorType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SensorChartViewModel>();
    final history = vm.history;
    final now = DateTime.now();
    final windowSec = vm.historyWindow.inSeconds.toDouble();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _getLabel(sensorType),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: const [ProfileAppBarAction()],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFa8e063), Color(0xFF56ab2f)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tarjeta del gráfico
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  color: Colors.white.withOpacity(0.9),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Gráfico en tiempo real',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(color: Colors.green.shade900)),
                        const SizedBox(height: 8),
                        Text(_getLabel(sensorType),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(color: Colors.black54)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          child: history.isEmpty
                              ? const Center(child: Text('Sin datos recientes'))
                              : LineChart(
                                  LineChartData(
                                    minY: history
                                            .map((s) => s.value)
                                            .reduce((a, b) => a < b ? a : b) -
                                        2,
                                    maxY: history
                                            .map((s) => s.value)
                                            .reduce((a, b) => a > b ? a : b) +
                                        2,
                                    minX: 0,
                                    maxX: windowSec,
                                    gridData: FlGridData(show: true),
                                    borderData: FlBorderData(show: true),
                                    titlesData: FlTitlesData(
                                      leftTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 40)),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 30,
                                          interval: windowSec / 4,
                                          getTitlesWidget: (v, _) {
                                            final secAgo =
                                                (windowSec - v).toInt();
                                            return Text('-${secAgo}s',
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.black54));
                                          },
                                        ),
                                      ),
                                      topTitles:
                                          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      rightTitles:
                                          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: history
                                            .map((s) {
                                              final x = windowSec -
                                                  now
                                                      .difference(s.timestamp)
                                                      .inSeconds
                                                      .toDouble();
                                              return FlSpot(x, s.value);
                                            })
                                            .toList(),
                                        isCurved: true,
                                        barWidth: 3,
                                        color: _getChartColor(sensorType),
                                        dotData: FlDotData(
                                          show: true,
                                          getDotPainter: (_, __, ___, ____) =>
                                              FlDotCirclePainter(
                                            radius: 4,
                                            color: _getChartColor(sensorType),
                                            strokeColor: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        _buildCurrentValue(context, vm),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                _buildLegend(context, vm),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentValue(
      BuildContext context, SensorChartViewModel vm) {
    if (vm.history.isEmpty) return const SizedBox();
    final now = DateTime.now();
    final visible = vm.history
        .where((s) => now.difference(s.timestamp) <= vm.historyWindow)
        .toList();
    if (visible.isEmpty) return const SizedBox();

    final current = visible.last;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Valor actual:',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: Colors.black87)),
          Text(current.getFormattedValue(),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(
                    color: _getChartColor(sensorType),
                    fontWeight: FontWeight.bold,
                  )),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context, SensorChartViewModel vm) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white.withOpacity(0.9),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Este gráfico muestra ${_getLabel(sensorType).toLowerCase()} '
          'durante los últimos ${vm.historyWindow.inSeconds} segundos.',
          style:
              Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black54),
        ),
      ),
    );
  }

  String _getLabel(SensorType type) {
    switch (type) {
      case SensorType.temperature:
        return 'Temperatura (°C)';
      case SensorType.humidity:
        return 'Humedad (%)';
      case SensorType.light:
        return 'Luz (lx)';
      case SensorType.co2:
        return 'CO₂ (ppm)';
    }
  }

  Color _getChartColor(SensorType type) {
    switch (type) {
      case SensorType.temperature:
        return Colors.red.shade700;
      case SensorType.humidity:
        return Colors.blue.shade700;
      case SensorType.light:
        return Colors.amber.shade700;
      case SensorType.co2:
        return Colors.green.shade700;
    }
  }
}
