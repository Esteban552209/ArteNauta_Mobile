import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Pedir permisos y obtener token
static Future<String?> inicializar() async {
  try {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    debugPrint('Permiso: ${settings.authorizationStatus}');

    await Future.delayed(const Duration(seconds: 2));

    final token = await _messaging.getToken();
    
    debugPrint('=====================================');
    debugPrint('FCM TOKEN: $token');
    debugPrint('=====================================');
    
    return token;
  } catch (e) {
    debugPrint('ERROR FCM: $e');
    return null;
  }
}
  // Escuchar notificaciones cuando la app está abierta
  static void escucharMensajes() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Notificación recibida: ${message.notification?.title}');
      debugPrint('Cuerpo: ${message.notification?.body}');
    });
  }
}