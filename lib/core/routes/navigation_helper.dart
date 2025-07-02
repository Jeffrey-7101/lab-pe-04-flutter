import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../../models/sensor.dart';
import '../../views/config_sensors/EditTemperatureScreen.dart';
import '../../views/config_sensors/EditHumidityScreen.dart';

/// Helper class para navegación con métodos de conveniencia
class NavigationHelper {
  
  /// Navega a una ruta y reemplaza toda la pila de navegación
  static void navigateAndReplaceAll(BuildContext context, String route) {
    Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
  }
  
  /// Navega a una ruta
  static void navigate(BuildContext context, String route, {Object? arguments}) {
    Navigator.pushNamed(context, route, arguments: arguments);
  }
  
  /// Navega y reemplaza la ruta actual
  static void navigateAndReplace(BuildContext context, String route, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, route, arguments: arguments);
  }
  
  /// Regresa a la pantalla anterior
  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
  
  /// Regresa a la pantalla anterior con resultado
  static void goBackWithResult<T>(BuildContext context, T result) {
    Navigator.pop(context, result);
  }
  
  // Métodos específicos para las rutas principales
  
  /// Navega al login
  static void toLogin(BuildContext context) {
    navigateAndReplaceAll(context, AppRoutes.login);
  }
  
  /// Navega al registro
  static void toRegister(BuildContext context) {
    navigate(context, AppRoutes.register);
  }
  
  /// Navega a la pantalla principal
  static void toMain(BuildContext context, [int initialTab = 0]) {
    navigateAndReplaceAll(context, AppRoutes.main);
  }
  
  /// Navega al perfil
  static void toProfile(BuildContext context) {
    navigate(context, AppRoutes.profile);
  }
  
  /// Navega al monitoring de un dispositivo
  static void toMonitoring(BuildContext context, String deviceId) {
    navigate(context, AppRoutes.monitoring, arguments: deviceId);
  }
  
  /// Navega al chart de un sensor
  static void toSensorChart(BuildContext context, {
    required dynamic sensorType,
    required String deviceId,
  }) {
    navigate(context, AppRoutes.sensorChart, arguments: {
      'sensorType': sensorType,
      'deviceId': deviceId,
    });
  }
  
  /// Navega a la pantalla de configuración de sensor
  static void toSensorConfig(BuildContext context, {
    required SensorType sensorType,
    required String deviceId,
  }) {
    switch (sensorType) {
      case SensorType.temperature:
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => EditTemperatureScreen(deviceId: deviceId),
          ),
        );
        break;
      case SensorType.humidity:
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => EditHumidityScreen(deviceId: deviceId),
          ),
        );
        break;
      default:
        // Para otros tipos de sensores, redirigir al gráfico por ahora
        toSensorChart(context, sensorType: sensorType, deviceId: deviceId);
    }
  }
  
  /// Navega a un tab específico del bottom navigation
  static void toTab(BuildContext context, int tabIndex) {
    switch (tabIndex) {
      case 0:
        navigateAndReplaceAll(context, AppRoutes.devices);
        break;
      case 1:
        navigateAndReplaceAll(context, AppRoutes.statistics);
        break;
      case 2:
        navigateAndReplaceAll(context, AppRoutes.notifications);
        break;
      default:
        navigateAndReplaceAll(context, AppRoutes.main);
    }
  }
  
  /// Cierra sesión y navega al login
  static void logout(BuildContext context) {
    toLogin(context);
  }
}
