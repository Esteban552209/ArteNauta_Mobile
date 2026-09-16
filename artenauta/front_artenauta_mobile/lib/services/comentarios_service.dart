import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'session_service.dart';

class ComentariosService {

  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await SessionService.getToken();
    return {
      ...ApiConfig.headers,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 1. GET: Obtener comentarios de una publicación
  Future<List<Map<String, dynamic>>> obtenerComentarios(int idPublicacion) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/comentarios/$idPublicacion');

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers);

      final decodedResponse = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(
          decodedResponse['mensaje'] ?? 'Error al obtener los comentarios',
        );
      }

      final List datos = decodedResponse is List
          ? decodedResponse
          : (decodedResponse['comentarios'] ?? decodedResponse['data'] ?? []);

      return List<Map<String, dynamic>>.from(datos);
    } catch (e) {
      throw Exception('Error al obtener comentarios: $e');
    }
  }

  // 2. POST: Crear un comentario
  Future<Map<String, dynamic>> crearComentario({
    required int idPublicacion,
    required String contenido,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/comentarios');

    try {
      final usuario = await SessionService.getUsuario();
      final idUsuario = usuario?['id_usuario'];

      if (idUsuario == null) {
        throw Exception('No hay una sesión de usuario activa');
      }

      final headers = await _getAuthHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'contenido': contenido,
          'id_publicacion': idPublicacion,
          'id_usuario_final': idUsuario,
        }),
      );

      final decodedResponse = jsonDecode(response.body);

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
          decodedResponse['mensaje'] ?? decodedResponse['error'] ?? 'Error al crear comentario',
        );
      }

      // ← NUEVO: notificar al artista
      await _notificarComentario(
        idPublicacion: idPublicacion,
        idUsuario: idUsuario,
        nombreUsuario: usuario?['nombre'] ?? 'Alguien',
      );

      return decodedResponse;
    } catch (e) {
      throw Exception('Error al crear comentario: $e');
    }
  }

  // ← NUEVO: envía notificación al backend
  Future<void> _notificarComentario({
    required int idPublicacion,
    required int idUsuario,
    required String nombreUsuario,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/notificaciones/comentario'),
        headers: headers,
        body: jsonEncode({
          'id_publicacion': idPublicacion,
          'id_usuario': idUsuario,
          'nombre_usuario': nombreUsuario,
        }),
      );
    } catch (e) {
      // No interrumpe el flujo si la notificación falla
    }
  }

  // 3. DELETE: Eliminar comentario
  Future<void> eliminarComentario(int idComentario) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/comentarios/$idComentario');

    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(url, headers: headers);

      if (response.statusCode != 200 && response.statusCode != 204) {
        final decodedResponse = jsonDecode(response.body);
        throw Exception(
          decodedResponse['mensaje'] ?? 'Error al eliminar el comentario',
        );
      }
    } catch (e) {
      throw Exception('Error al eliminar comentario: $e');
    }
  }
}