import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/notifications_viewmodel.dart';
import 'viewmodels/device_viewmodel.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/devices/device_screen.dart';
import 'views/sensor/sensors_screen.dart';
import 'views/home/home_screen.dart';
import 'views/profile/profile_screen.dart';
import 'views/statistics/statistics_screen.dart';
import 'views/notifications/notifications_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        ChangeNotifierProvider(create: (_) => DevicesViewModel()),
      ],
      child: MaterialApp(
        title: 'Invernadero IoT',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'Roboto',
        ),
        home: const AuthGate(),
        routes: {
          '/register':      (_) => const RegisterScreen(),
          '/home':          (_) => const HomeScreen(),
          '/profile':       (_) => const ProfileScreen(),
          '/dashboard':     (_) => const DashboardScreen(),
          '/notifications': (_) => const NotificationsScreen(),
          '/devices':       (_) => const DevicesScreen(),
          // Nota: en el route '/sensors' pasamos un valor por defecto, pero 
          // normalmente navegarías con `Navigator.pushNamed(context, '/sensors', arguments: deviceId)`
          '/sensors':       (_) => const SensorsScreen(deviceId: 'dev1'),
        },
      ),
    );
  }
}

/// Este widget decide si mostrar LoginScreen o DevicesScreen (o HomeScreen).
/// Observa el estado de FirebaseAuth y reconstruye según cambie authStateChanges().
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mientras Flutter comprueba el estado (esperando conexión), mostramos un indicador:
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Si no hay usuario logueado, vamos a LoginScreen:
        if (snapshot.data == null) {
          return const LoginScreen();
        }

        // Existe un usuario: abrimos directamente DevicesScreen (o HomeScreen si prefieres):
        return const DevicesScreen();
      },
    );
  }
}
