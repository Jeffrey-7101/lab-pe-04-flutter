import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../models/sensor.dart';
import '../../viewmodels/sensor_chart_viewmodel.dart';
import '../../viewmodels/device_viewmodel.dart';

class SensorChartScreen extends StatelessWidget {
  /// Ahora opcional: si es null, elegimos el primero
  final String? deviceId;
  final SensorType sensorType;

  const SensorChartScreen({
    Key? key,
    this.deviceId,
    required this.sensorType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Si no recibimos deviceId, usamos el primero del VM
    final vmDevices = context.read<DevicesViewModel>();
    final actualDeviceId = deviceId ??
        (vmDevices.devices.isNotEmpty
            ? vmDevices.devices.first.id
            : '');

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
    final vm = Provider.of<SensorChartViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getLabel(sensorType)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gráfico en tiempo real',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(_getLabel(sensorType),
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    _buildChart(context, vm),
                    const SizedBox(height: 16),
                    _buildCurrentValue(context, vm),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(
      BuildContext context, SensorChartViewModel vm) {
    final history = vm.history;
    if (history.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(child: Text('Esperando datos…')),
      );
    }

    final windowSec = vm.historyWindow.inSeconds.toDouble();
    final now = DateTime.now();
    final visible = history
        .where((s) =>
            now.difference(s.timestamp).inSeconds <= windowSec)
        .toList();
    if (visible.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(child: Text('Sin datos recientes')),
      );
    }

    final minY = visible
            .map((s) => s.value)
            .reduce((a, b) => a < b ? a : b) -
        2;
    final maxY = visible
            .map((s) => s.value)
            .reduce((a, b) => a > b ? a : b) +
        2;

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          minX: 0,
          maxX: windowSec,
          lineBarsData: [
            LineChartBarData(
              spots: visible.map((s) {
                final x = windowSec -
                    now
                        .difference(s.timestamp)
                        .inSeconds
                        .toDouble();
                return FlSpot(x, s.value);
              }).toList(),
              isCurved: true,
              color: _getChartColor(sensorType),
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (_, __, ___, ____) =>
                    FlDotCirclePainter(
                  radius: 4,
                  color: _getChartColor(sensorType),
                  strokeWidth: 1.5,
                  strokeColor: Colors.white,
                ),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true, reservedSize: 40)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 5,
                getTitlesWidget: (value, _) {
                  final secAgo = (windowSec - value).toInt();
                  return Text('-${secAgo}s',
                      style:
                          const TextStyle(fontSize: 10));
                },
              ),
            ),
            rightTitles: const AxisTitles(
                sideTitles:
                    SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles:
                    SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
        ),
        duration: Duration.zero,
      ),
    );
  }

  Widget _buildCurrentValue(
      BuildContext context, SensorChartViewModel vm) {
    if (vm.history.isEmpty) return const SizedBox();
    final now = DateTime.now();
    final visible = vm.history
        .where((s) =>
            now.difference(s.timestamp) <=
            vm.historyWindow)
        .toList();
    if (visible.isEmpty) return const SizedBox();

    final current = visible.last;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text('Valor actual:',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium),
          Text(current.getFormattedValue(),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    color:
                        _getChartColor(sensorType),
                    fontWeight: FontWeight.bold,
                  )),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Este gráfico muestra ${_getLabel(sensorType).toLowerCase()} '
          'de este dispositivo en tiempo real durante los últimos '
          '${const Duration(seconds: 30).inSeconds} segundos.',
          style:
              Theme.of(context).textTheme.bodyMedium,
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
        return Colors.red;
      case SensorType.humidity:
        return Colors.blue;
      case SensorType.light:
        return Colors.amber.shade700;
      case SensorType.co2:
        return Colors.green.shade700;
    }
  }
}
