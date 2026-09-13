import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'session_service.dart'; 

class AuthService {
  
  // 1. INICIO DE SESIÓN (LOGIN)
  Future<Map<String, dynamic>> iniciarSesion({
    required String email,
    required String clave,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({
          'email': email,
          'password': clave, 
        }),
      );

      final decodedResponse = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(decodedResponse['mensaje'] ?? 'Error desconocido al iniciar sesión');
      }

      await SessionService.guardarSesion(
        decodedResponse['token'],
        decodedResponse['usuario'],
      );

      return decodedResponse;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // 2. REGISTRO DE USUARIO
  Future<Map<String, dynamic>> registrarUsuario({
    required String nombre,
    required String apellido,
    required String telefono,
    required String email,
    required String clave,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/usuario/registro');

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({
          'nombre': nombre,
          'apellido': apellido,
          'telefono': telefono,
          'email': email,
          'clave': clave,
        }),
      );

      final decodedResponse = jsonDecode(response.body);

      if (response.statusCode != 201) {
        throw Exception(decodedResponse['error'] ?? 'Error desconocido al registrar'); 
      }

      return decodedResponse; 
      
    } catch (e) {
      throw Exception('Error de conexión: $e'); 
    }
  }
}