import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'core/routes/app_router.dart';
import 'core/routes/app_routes.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/notifications_viewmodel.dart';
import 'viewmodels/device_viewmodel.dart';
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
          // Configuración de tema para mejor apariencia
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
        // Usar el generador de rutas centralizado
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: AppRoutes.initial,
      ),
    );
  }
}
