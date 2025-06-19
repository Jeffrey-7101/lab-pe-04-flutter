import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
      ],
      child: MaterialApp(
        title: 'Invernadero IoT',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'Roboto',
        ),
        initialRoute: '/login',
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
