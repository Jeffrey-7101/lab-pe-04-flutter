/// Definición de rutas de la aplicación
/// Centraliza todas las rutas para mejor mantenimiento y consistencia
class AppRoutes {
  // Rutas de autenticación
  static const String login = '/login';
  static const String register = '/register';
  
  // Ruta principal (con bottom navigation)
  static const String main = '/main';
  
  // Tabs del bottom navigation (usando índices)
  static const String devices = '/main/devices';              // index: 0
  static const String statistics = '/main/statistics';        // index: 1
  static const String notifications = '/main/notifications';  // index: 2
  
  // Rutas secundarias
  static const String profile = '/profile';
  static const String monitoring = '/monitoring';
  static const String sensorChart = '/sensor-chart';
  
  // Ruta inicial
  static const String initial = '/';
}
