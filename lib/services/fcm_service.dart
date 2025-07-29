import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FCMService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static Future<void> init() async {
    await _fcm.requestPermission();

    final token = await _fcm.getToken();
    debugPrint('🔑 FCM Token: $token');

    // Escucha notificaciones en primer plano
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('📩 Notificación en foreground: ${message.notification?.title}');
    });

    // Notificación tocada con la app en background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('🚀 App abierta desde notificación: ${message.notification?.title}');
    });

    // App abierta directamente desde una notificación
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('🟢 App lanzada por notificación: ${initialMessage.notification?.title}');
    }
  }

  static Future<void> saveTokenToDatabase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("❌ Usuario no autenticado, no se puede guardar el token.");
      return;
    }

    final token = await _fcm.getToken();
    if (token == null) {
      debugPrint("❌ Token FCM no disponible.");
      return;
    }

    final ref = FirebaseDatabase.instance.ref("fcmTokens/${user.uid}");
    await ref.set({
      "token": token,
      "email": user.email ?? '',
      "updatedAt": DateTime.now().toUtc().toIso8601String(),
    });

    debugPrint("✅ Token FCM guardado para UID: ${user.uid}");
  }
}
