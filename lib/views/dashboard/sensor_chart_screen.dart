import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/sensor.dart';
import '../../viewmodels/sensor_chart_viewmodel.dart';

class SensorChartScreen extends StatelessWidget {
  final SensorType sensorType;
  final String deviceId;

  const SensorChartScreen({
    super.key,
    required this.sensorType,
    required this.deviceId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SensorChartViewModel(deviceId: deviceId),
      child: _SensorChartView(sensorType: sensorType),
    );
  }
}

class _SensorChartView extends StatelessWidget {
  final SensorType sensorType;

  const _SensorChartView({required this.sensorType});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SensorChartViewModel>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${vm.deviceName} - ${_getLabel(sensorType)}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gráfico en tiempo real',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getLabel(sensorType),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
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

  Widget _buildChart(BuildContext context, SensorChartViewModel vm) {
    final history = vm.sensorHistory[sensorType] ?? [];
    
    if (history.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(child: Text('Esperando datos...')),
      );
    }

    // Ventana de tiempo en segundos
    final windowSeconds = vm.historyWindow.inSeconds.toDouble();
    final now = DateTime.now();
    
    // Solo los datos dentro de la ventana
    final visible = history.where((s) => 
      now.difference(s.timestamp).inSeconds <= windowSeconds).toList();
    
    if (visible.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(child: Text('Sin datos recientes')),
      );
    }

    // Normaliza el eje X: 0 = inicio de la ventana, windowSeconds = ahora
    final minY = visible.map((s) => s.value).reduce((a, b) => a < b ? a : b) - 2;
    final maxY = visible.map((s) => s.value).reduce((a, b) => a > b ? a : b) + 2;
    
    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          minX: 0,
          maxX: windowSeconds,
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var s in visible)
                  FlSpot(
                    windowSeconds - now.difference(s.timestamp).inSeconds.toDouble(),
                    s.value,
                  ),
              ],
              isCurved: true,
              color: _getChartColor(context, sensorType),
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: _getChartColor(context, sensorType),
                    strokeWidth: 1.5,
                    strokeColor: Colors.white,
                  );
                },
              ),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final secondsAgo = (windowSeconds - value).toInt();
                  return Text('-${secondsAgo}s', 
                    style: const TextStyle(fontSize: 10));
                },
                interval: 5,
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: true,
          ),
          borderData: FlBorderData(show: true),
        ),
        duration: Duration.zero, // Sin animación para evitar defectos al actualizar en tiempo real
      ),
    );
  }

  Widget _buildCurrentValue(BuildContext context, SensorChartViewModel vm) {
    final history = vm.sensorHistory[sensorType] ?? [];
    if (history.isEmpty) return const SizedBox();
    
    final now = DateTime.now();
    final visible = history.where((s) => 
      now.difference(s.timestamp).inSeconds <= vm.historyWindow.inSeconds).toList();
    
    if (visible.isEmpty) return const SizedBox();
    
    final current = visible.last;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Valor actual:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            current.getFormattedValue(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: _getChartColor(context, sensorType),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Este gráfico muestra los datos de ${_getLabel(sensorType).toLowerCase()} '
              'en tiempo real durante los últimos 30 segundos.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Los datos se actualizan cada segundo con nuevas mediciones simuladas.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
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

  Color _getChartColor(BuildContext context, SensorType type) {
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
