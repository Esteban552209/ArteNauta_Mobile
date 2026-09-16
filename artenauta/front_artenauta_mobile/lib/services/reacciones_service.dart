import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'session_service.dart';

class ReaccionesService {
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await SessionService.getToken();
    return {
      ...ApiConfig.headers,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// 1. POST: Alternar Like (Toggle)
  Future<bool> toggleLike({required int idPublicacion}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/publicaciones/$idPublicacion/like');

    try {
      final usuario = await SessionService.getUsuario();
      final idUsuarioRaw = usuario?['id_usuario'];
      final idUsuario = int.tryParse(idUsuarioRaw?.toString() ?? '');

      if (idUsuario == null) {
        throw Exception('No hay una sesión de usuario activa');
      }

      final headers = await _getAuthHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'id_usuario': idUsuario,
        }),
      );

      final decodedResponse = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(
          decodedResponse['error'] ?? decodedResponse['mensaje'] ?? 'Error al procesar el Me Gusta',
        );
      }

      final bool dioLike = decodedResponse['registrado'] ?? false;

      // Si el usuario dio 'Like' (true), enviamos la notificación
      if (dioLike) {
        await _notificarLike(
          idPublicacion: idPublicacion,
          idUsuario: idUsuario,
          nombreUsuario: usuario?['nombre'] ?? 'Alguien',
        );
      }

      return dioLike;
    } catch (e) {
      throw Exception('Error al procesar el me gusta: $e');
    }
  }

  /// Envía la notificación de Like al backend
  Future<void> _notificarLike({
    required int idPublicacion,
    required int idUsuario,
    required String nombreUsuario,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/notificaciones/like'),
        headers: headers,
        body: jsonEncode({
          'id_publicacion': idPublicacion,
          'id_usuario': idUsuario,
          'nombre_usuario': nombreUsuario,
        }),
      );
    } catch (e) {
      // Ignora si la notificación falla para no pausar el flujo
    }
  }

  /// 2. GET: Obtener información completa de Likes
  Future<Map<String, dynamic>> obtenerLikesInfo({required int idPublicacion}) async {
    final usuario = await SessionService.getUsuario();
    final idUsuarioRaw = usuario?['id_usuario'];
    final idUsuario = int.tryParse(idUsuarioRaw?.toString() ?? '');
    final queryParams = idUsuario != null ? '?id_usuario=$idUsuario' : '';
    final url = Uri.parse('${ApiConfig.baseUrl}/publicaciones/$idPublicacion/likes-info$queryParams');

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers);

      final decodedResponse = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(
          decodedResponse['error'] ?? 'Error al obtener la información de Me Gusta',
        );
      }

      return {
        'totalLikes': decodedResponse['totalLikes'] ?? 0,
        'usuarioDioLike': decodedResponse['usuarioDioLike'] ?? false,
      };
    } catch (e) {
      throw Exception('Error al obtener info de me gusta: $e');
    }
  }
}