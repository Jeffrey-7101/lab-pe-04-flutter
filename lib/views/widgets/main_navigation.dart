import 'package:flutter/material.dart';
import '../devices/device_screen.dart';
import '../statistics/statistics_screen.dart';
import '../notifications/notifications_screen.dart';
import 'bottom_navbar.dart';

/// Widget para gestionar la navegación principal con pestañas en la parte inferior
/// Implementación simplificada usando IndexedStack para mantener el estado de cada pestaña
class MainNavigation extends StatefulWidget {
  final int initialIndex;
  
  const MainNavigation({
    super.key, 
    this.initialIndex = 0,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // Estado para controlar el índice actual
  late int _currentIndex;
  
  // Pantallas principales de la aplicación (constantes)
  static const List<Widget> _screens = [
    DevicesScreen(),
    DashboardScreen(),
    NotificationsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  // Maneja la navegación entre pestañas
  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Previene salir de la app con botón atrás si no estamos en la primera pestaña
      canPop: _currentIndex == 0,
      onPopInvoked: (didPop) {
        if (!didPop && _currentIndex != 0) {
          // Si no esta en la primera pestaña, volver a ella
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        // Usando IndexedStack para mantener el estado de cada pantalla
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        // Barra de navegación inferior
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),
      ),
    );
  }
}
