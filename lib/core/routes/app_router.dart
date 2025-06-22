import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app_routes.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/register_screen.dart';
import '../../views/main/main_screen.dart';
import '../../views/profile/profile_screen.dart';
import '../../views/monitoring/monitoring_screen.dart';
import '../../views/statistics/sensor_chart_screen.dart';

/// Generador de rutas centralizado
/// Maneja toda la navegación de la aplicación de forma consistente
class AppRouter {
  
  /// Genera las rutas basándose en el RouteSettings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    
    switch (settings.name) {
      // Ruta inicial - redirige según el estado de autenticación
      case AppRoutes.initial:
        return _createRoute(
          const AuthWrapper(),
          settings: settings,
        );
      
      // Rutas de autenticación
      case AppRoutes.login:
        return _createRoute(
          const LoginScreen(),
          settings: settings,
        );
      
      case AppRoutes.register:
        return _createRoute(
          const RegisterScreen(),
          settings: settings,
        );
      
      // Ruta principal con bottom navigation
      case AppRoutes.main:
        return _createRoute(
          _requireAuth(const MainScreen()),
          settings: settings,
        );
      
      // Tabs individuales (para navegación programática)
      case AppRoutes.devices:
        return _createRoute(
          _requireAuth(const MainScreen(initialTab: 0)),
          settings: settings,
        );
      
      case AppRoutes.statistics:
        return _createRoute(
          _requireAuth(const MainScreen(initialTab: 1)),
          settings: settings,
        );
      
      case AppRoutes.notifications:
        return _createRoute(
          _requireAuth(const MainScreen(initialTab: 2)),
          settings: settings,
        );
      
      // Rutas secundarias
      case AppRoutes.profile:
        return _createRoute(
          _requireAuth(const ProfileScreen()),
          settings: settings,
        );
      
      case AppRoutes.monitoring:
        if (args is String) {
          return _createRoute(
            _requireAuth(MonitoringScreen(deviceId: args)),
            settings: settings,
          );
        }
        return _createErrorRoute('Device ID required for monitoring');
      
      case AppRoutes.sensorChart:
        if (args is Map<String, dynamic>) {
          return _createRoute(
            _requireAuth(SensorChartScreen(
              sensorType: args['sensorType'],
              deviceId: args['deviceId'],
            )),
            settings: settings,
          );
        }
        return _createErrorRoute('Sensor type and device ID required');
      
      // Ruta no encontrada
      default:
        return _createErrorRoute('Route not found: ${settings.name}');
    }
  }
  
  /// Crea una ruta estándar
  static Route<dynamic> _createRoute(
    Widget page, {
    RouteSettings? settings,
    bool fullscreenDialog = false,
  }) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
      fullscreenDialog: fullscreenDialog,
    );
  }
  
  /// Wrapper para rutas que requieren autenticación
  static Widget _requireAuth(Widget child) {
    return AuthGuard(child: child);
  }
  
  /// Crea una ruta de error
  static Route<dynamic> _createErrorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.initial, 
                  (route) => false,
                ),
                child: const Text('Ir al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget que verifica el estado de autenticación
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mientras carga el estado de autenticación
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // Si hay usuario autenticado
        if (snapshot.hasData && snapshot.data != null) {
          return const MainScreen();
        }
        
        // Si no hay usuario autenticado
        return const LoginScreen();
      },
    );
  }
}

/// Guard que protege rutas que requieren autenticación
class AuthGuard extends StatelessWidget {
  final Widget child;
  
  const AuthGuard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Si está cargando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // Si no está autenticado, redirigir al login
        if (!snapshot.hasData || snapshot.data == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.login,
              (route) => false,
            );
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // Si está autenticado, mostrar el contenido
        return child;
      },
    );
  }
}
