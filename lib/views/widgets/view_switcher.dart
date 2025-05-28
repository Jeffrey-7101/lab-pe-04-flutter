import 'package:flutter/material.dart';

class ViewSwitcher extends StatelessWidget {
  final bool isMonitoring;
  final VoidCallback onMonitoringTap;
  final VoidCallback onSensorsTap;

  const ViewSwitcher({
    super.key,
    required this.isMonitoring,
    required this.onMonitoringTap,
    required this.onSensorsTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = Colors.green.shade700;
    final inactiveColor = Colors.black54;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onMonitoringTap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Monitor',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isMonitoring ? FontWeight.bold : FontWeight.normal,
                    color: isMonitoring ? activeColor : inactiveColor,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 2,
                  width: 60,
                  decoration: BoxDecoration(
                    color: isMonitoring ? activeColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 24,
              child: VerticalDivider(thickness: 1, color: Colors.grey),
            ),
          ),

          GestureDetector(
            onTap: onSensorsTap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sensores',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: !isMonitoring ? FontWeight.bold : FontWeight.normal,
                    color: !isMonitoring ? activeColor : inactiveColor,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 2,
                  width: 60,
                  decoration: BoxDecoration(
                    color: !isMonitoring ? activeColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
