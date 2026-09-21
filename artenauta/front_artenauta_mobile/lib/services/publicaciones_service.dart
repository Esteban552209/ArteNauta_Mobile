import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'session_service.dart';

class PublicacionesService {
  
  /// Helper para incluir el Token de Autenticación en los Encabezados
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await SessionService.getToken();
    return {
      ...ApiConfig.headers,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 1. GET: Obtener todas las publicaciones activas
  Future<List<Map<String, dynamic>>> obtenerPublicaciones() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/Muro-Publicaciones');

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers);

      final decodedResponse = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(decodedResponse['mensaje'] ?? 'Error al obtener publicaciones');
      }

      final List datos = decodedResponse is List 
          ? decodedResponse 
          : (decodedResponse['publicaciones'] ?? decodedResponse['data'] ?? []);

      return List<Map<String, dynamic>>.from(datos);
    } catch (e) {
      throw Exception('Error al obtener publicaciones: $e');
    }
  }

  // 2. GET: Carga todas las categorías disponibles
  static Future<List<Map<String, dynamic>>> obtenerCategorias() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/categorias');

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers);

      final decodedResponse = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(decodedResponse['mensaje'] ?? 'Error al obtener categorías');
      }

      final List datos = decodedResponse is List 
          ? decodedResponse 
          : (decodedResponse['categorias'] ?? decodedResponse['data'] ?? []);

      return List<Map<String, dynamic>>.from(datos);
    } catch (e) {
      throw Exception('Error al obtener categorías: $e');
    }
  }

  // 3. POST: Crea una nueva publicación asignada al usuario logueado
  static Future<Map<String, dynamic>> crearPublicacion({
    required String titulo,
    required String descripcion,
    required String imagenUrl,
    required int idCategoria,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/publicaciones');

    try {
      final usuario = await SessionService.getUsuario();
      final idUsuario = usuario?['id_usuario'];

      if (idUsuario == null) {
        throw Exception('No se encontró una sesión activa de usuario.');
      }

      final headers = await _getAuthHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'titulo': titulo,
          'descripcion': descripcion,
          'contenido': imagenUrl,
          'id_categoria': idCategoria,
          'id_usuario_artista': idUsuario,
        }),
      );

      final decodedResponse = jsonDecode(response.body);

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(decodedResponse['mensaje'] ?? decodedResponse['error'] ?? 'Error al crear la publicación');
      }

      return decodedResponse;
    } catch (e) {
      throw Exception('Error al registrar la publicación: $e');
    }
  }

  // 4. GET: Obtener publicaciones creadas por un usuario específico
  static Future<List<Map<String, dynamic>>> getPublicacionesPorUsuario(int idArtista) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/publicaciones/artista/$idArtista');

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers);

      final decodedResponse = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(decodedResponse['mensaje'] ?? 'Error al obtener publicaciones del usuario');
      }

      final List datos = decodedResponse is List 
          ? decodedResponse 
          : (decodedResponse['publicaciones'] ?? decodedResponse['data'] ?? []);

      return List<Map<String, dynamic>>.from(datos);
    } catch (e) {
      throw Exception('Error al obtener publicaciones por usuario: $e');
    }
  }

  // 5. PUT/PATCH: Editar información de una publicación
  static Future<Map<String, dynamic>> editarPublicacion({
    required int idPublicacion,
    required String titulo,
    required String descripcion,
    double? precio,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/publicaciones/$idPublicacion');

    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode({
          'titulo': titulo,
          'descripcion': descripcion
        }),
      );

      final decodedResponse = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(decodedResponse['mensaje'] ?? 'Error al editar la publicación');
      }

      return decodedResponse;
    } catch (e) {
      throw Exception('Error al editar la publicación: $e');
    }
  }

  // 6. DELETE: Eliminar una publicación
  static Future<void> eliminarPublicacion(int idPublicacion) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/publicaciones/$idPublicacion');

    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(url, headers: headers);

      if (response.statusCode != 200 && response.statusCode != 204) {
        final decodedResponse = jsonDecode(response.body);
        throw Exception(decodedResponse['mensaje'] ?? 'Error al eliminar la publicación');
      }
    } catch (e) {
      throw Exception('Error al eliminar la publicación: $e');
    }
  }
}