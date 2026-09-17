import 'session_service.dart';

class ApiConfig {
  // Usar la IP del PC para probar en dispositivo físico, o 10.0.2.2 para el emulador de Android
  static const String baseUrl = 'http://192.168.1.90:3000/mobile'; 
  
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Para requests que necesitan el token (conversaciones, mensajes, etc.)
  static Future<Map<String, String>> headersConToken() async {
    final token = await SessionService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}