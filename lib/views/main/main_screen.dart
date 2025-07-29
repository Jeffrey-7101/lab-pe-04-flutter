import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/routes/app_routes.dart';
import '../devices/device_screen.dart';
import '../statistics/statistics_screen.dart';
import '../notifications/notifications_screen.dart';
import '../widgets/bottom_navbar.dart';

/// Pantalla principal que maneja la navegación por tabs
/// Utiliza IndexedStack para mantener el estado de cada tab
class MainScreen extends StatefulWidget {
  final int initialTab;
  
  const MainScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  late int _currentIndex;
  
  // Lista de pantallas para cada tab
  static const List<Widget> _screens = [
    DevicesScreen(),
    StatisticsScreen(),
    NotificationsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab.clamp(0, _screens.length - 1);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Maneja el cambio de tab
  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  /// Maneja el botón de retroceso del sistema
  Future<bool> _onWillPop() async {
    // Si no estamos en el primer tab, volver al primer tab
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      return false; // No salir de la app
    }
    
    // Si estamos en el primer tab, mostrar diálogo de confirmación
    return await _showExitDialog() ?? false;
  }

  /// Muestra diálogo de confirmación para salir de la app
  Future<bool?> _showExitDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Salir de la aplicación'),
        content: const Text('¿Estás seguro de que quieres salir?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            // Cerrar la aplicación completamente
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        // Usar IndexedStack para mantener el estado de cada pantalla
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        // Bottom navigation bar mejorado
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),
      ),
    );
  }
}

/// Extension para agregar métodos de navegación específicos
extension MainScreenNavigation on BuildContext {
  /// Navega a un tab específico
  void navigateToTab(int tabIndex) {
    Navigator.of(this).pushNamedAndRemoveUntil(
      AppRoutes.main,
      (route) => false,
      arguments: {'initialTab': tabIndex},
    );
  }
  
  /// Navega al tab de dispositivos
  void navigateToDevices() => navigateToTab(0);
  
  /// Navega al tab de estadísticas
  void navigateToStatistics() => navigateToTab(1);
  
  /// Navega al tab de notificaciones
  void navigateToNotifications() => navigateToTab(2);
}
