import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'views/widgets/main_navigation.dart';
import 'repositories/auth_repository.dart';
import 'services/fcm_service.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('🛑 Notificación en background: ${message.notification?.title}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      rethrow;
    }
  }

  await FCMService.init();

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
        ),        home: const AuthWrapper(),
        // Sistema de rutas simplificado con verificación de autenticación
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
        // Navegación a las pestañas principales con MainNavigation
        onGenerateRoute: (settings) {
          // Rutas de navegación con barra inferior
          final tabRoutes = {
            '/devices': 0,
            '/dashboard': 1, 
            '/notifications': 2,
          };
          
          // Si es una ruta de tab, usar el MainNavigation con el índice adecuado
          if (tabRoutes.containsKey(settings.name)) {
            return MaterialPageRoute(
              builder: (_) => MainNavigation(initialIndex: tabRoutes[settings.name]!),
              settings: settings,
            );
          }
          
          // Para cualquier otra ruta, verificar autenticación
          if (FirebaseAuth.instance.currentUser == null &&
              settings.name != '/login' && settings.name != '/register') {
            return MaterialPageRoute(
              builder: (_) => const LoginScreen(),
              settings: const RouteSettings(name: '/login'),
            );
          }
          
          // Si no es una ruta conocida, ir a la ruta por defecto
          return MaterialPageRoute(
            builder: (_) => const AuthWrapper(),
            settings: settings,
          );
        }
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
          // Usar MainNavigation en lugar de DevicesScreen directamente
          return const MainNavigation(initialIndex: 0);
        }
        // Si no hay usuario autenticado, mostramos la pantalla de login
        return const LoginScreen();
      },
    );
  }
}
