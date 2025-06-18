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
import 'views/home/home_screen.dart';
import 'views/profile/profile_screen.dart';
import 'views/statistics/statistics_screen.dart';
import 'views/notifications/notifications_screen.dart';
import 'views/devices/device_screen.dart';
import 'repositories/auth_repository.dart';

Future<void> main() async { 
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      rethrow;
    }
  }
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
        Provider<AuthRepository>(create: (_) => AuthRepository()),
      ],
      child: MaterialApp(
        title: 'Invernadero IoT',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'Roboto',
        ),
        home: const AuthWrapper(),
        routes: {
          '/login':         (_) => const LoginScreen(),
          '/register':      (_) => const RegisterScreen(),
          '/home':          (_) => const HomeScreen(),
          '/profile':       (_) => const ProfileScreen(),
          '/dashboard':     (_) => const DashboardScreen(),
          '/notifications': (_) => const NotificationsScreen(),
          '/devices':       (_) => const DevicesScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = Provider.of<AuthRepository>(context, listen: false);
    
    // StreamBuilder escucha cambios en el estado de autenticación
    return StreamBuilder<User?>(
      stream: authRepository.authState,
      builder: (context, snapshot) {
        // Si el usuario está autenticado (no es null)
        if (snapshot.hasData && snapshot.data != null) {
          // Redirige a la pantalla de dispositivos
          return const DevicesScreen();
        }
        // Si no hay usuario autenticado, mostramos la pantalla de login
        return const LoginScreen();
      },
    );
  }
}
