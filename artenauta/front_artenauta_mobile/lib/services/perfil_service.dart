import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'session_service.dart';

class PerfilService {

  Future<Map<String, String>> _headers() async {
    final token = await SessionService.getToken();
    return {
      ...ApiConfig.headers,
      'Authorization': 'Bearer $token',
    };
  }

  // GET /perfil — obtener perfil completo del usuario
  Future<Map<String, dynamic>> getPerfil() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/perfil');
    try {
      final response = await http.get(url, headers: await _headers());
      if (response.statusCode != 200) {
        throw Exception('Error al obtener perfil');
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // PATCH /perfil/usuario — actualizar nombre, apellido y teléfono
  Future<Map<String, dynamic>> actualizarUsuario({
    required String nombre,
    required String apellido,
    required String telefono,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/perfil/usuario');
    try {
      final response = await http.patch(
        url,
        headers: await _headers(),
        body: jsonEncode({
          'nombre': nombre,
          'apellido': apellido,
          'telefono': telefono,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception('Error al actualizar usuario');
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // PATCH /perfil — actualizar descripción y ocupación
  Future<Map<String, dynamic>> actualizarPerfil({
    required String descripcion,
    required String ocupacion,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/perfil');
    try {
      final response = await http.patch(
        url,
        headers: await _headers(),
        body: jsonEncode({
          'descripcion': descripcion,
          'ocupacion': ocupacion,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception('Error al actualizar perfil');
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}