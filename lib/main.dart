import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/notifications_viewmodel.dart';  // ← importa tu VM
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/home/home_screen.dart';
import 'views/profile/profile_screen.dart';
import 'views/dashboard/dashboard_screen.dart';
import 'views/notifications/notifications_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationsViewModel()), 
      ],
      child: MaterialApp(
        title: 'Invernadero IoT',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'Roboto',
        ),
        initialRoute: '/home',
        routes: {
          '/login':         (_) => const LoginScreen(),
          '/home':          (_) => const HomeScreen(),
          '/register':      (_) => const RegisterScreen(),
          '/profile':       (_) => const ProfileScreen(),
          '/dashboard':     (_) => const DashboardScreen(),
          '/notifications': (_) => const NotificationsScreen(),
        },
      ),
    );
  }
}
