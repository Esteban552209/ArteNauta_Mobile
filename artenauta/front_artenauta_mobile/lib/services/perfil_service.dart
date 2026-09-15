import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'session_service.dart';

class PerfilService {
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await SessionService.getToken();
    return {
      ...ApiConfig.headers,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // OBTENER PERFIL COMPLETO (GET /perfil)
  static Future<Map<String, dynamic>> obtenerPerfil() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/perfil'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      } else {
        final body = jsonDecode(response.body);
        throw Exception(body['error'] ?? 'Error al obtener el perfil.');
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  // ACTUALIZAR DATOS DE USUARIO (PATCH /perfil/usuario)
  static Future<Map<String, dynamic>> actualizarUsuario({
    required String nombre,
    required String apellido,
    required int? telefono,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/perfil/usuario'),
        headers: headers,
        body: jsonEncode({
          'nombre': nombre,
          'apellido': apellido,
          'telefono': telefono,
        }),
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      } else {
        final body = jsonDecode(response.body);
        throw Exception(body['error'] ?? 'Error al actualizar el usuario.');
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  // ACTUALIZAR PERFIL EXTENDIDO (PATCH /perfil)
  static Future<Map<String, dynamic>> actualizarPerfilExtendido({
    String? descripcion,
    String? ocupacion,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/perfil'),
        headers: headers,
        body: jsonEncode({'descripcion': descripcion, 'ocupacion': ocupacion}),
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      } else {
        final body = jsonDecode(response.body);
        throw Exception(
          body['error'] ?? 'Error al actualizar la información del perfil.',
        );
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  // SOLICITAR SER ARTISTA (POST /notificaciones/solicitudes)
  static Future<void> enviarSolicitudArtista() async {
    try {
      final usuario = await SessionService.getUsuario();
      final idUsuario = usuario?['id_usuario'];
      if (idUsuario == null) throw Exception('No hay sesión activa');

      final headers = await _getAuthHeaders();

      // Verificar si ya tiene solicitud pendiente
      final checkRes = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/notificaciones/solicitudes/pendiente?id_usuario=$idUsuario',
        ),
        headers: headers,
      );

      if (checkRes.statusCode == 200) {
        final body = jsonDecode(checkRes.body);
        if (body['tieneSolicitud'] == true) {
          throw Exception(
            'Ya tienes una solicitud pendiente. Espera a que el administrador la revise.',
          );
        }
      }

      // Enviar solicitud
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/notificaciones/solicitudes'),
        headers: headers,
        body: jsonEncode({
          'tipo_solicitud': 'artista',
          'id_usuario': idUsuario,
        }),
      );

      if (response.statusCode != 201) {
        final body = jsonDecode(response.body);
        throw Exception(body['error'] ?? 'Error al enviar la solicitud.');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
