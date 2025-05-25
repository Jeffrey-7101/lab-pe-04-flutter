import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';   
import 'viewmodels/login_viewmodel.dart';
import 'views/auth/login_screen.dart';
import 'views/home/home_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/profile/profile_screen.dart';

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
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: MaterialApp(
        title: 'Invernadero IoT',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'Roboto',
        ),
        initialRoute: '/home',
        routes: {
          '/login': (_) => LoginScreen(),
          '/home':  (_) => const HomeScreen(),
          '/register': (_) => const RegisterScreen(),
          '/profile': (_) => const ProfileScreen(),
        },
      ),
    );
  }
}
