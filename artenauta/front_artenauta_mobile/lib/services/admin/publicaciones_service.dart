import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class PublicacionesService {
  
  // GET: Obtener publicaciones
  Future<List<dynamic>> getPublicaciones(String token, {String? buscar}) async {
    try {
      Uri url = Uri.parse('${ApiConfig.baseUrl}/Muro-Publicaciones');
      
      if (buscar != null && buscar.isNotEmpty) {
        url = url.replace(queryParameters: {'buscar': buscar});
      }

      final response = await http.get(
        url,
        headers: {
          ...ApiConfig.headers,
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Error desconocido al cargar publicaciones');
      }
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  // DELETE: Eliminar una publicación por su ID
  Future<void> eliminarPublicacion({
    required String token,
    required int idPublicacion,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/publicaciones/$idPublicacion');

      final response = await http.delete(
        url,
        headers: {
          ...ApiConfig.headers,
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Error al eliminar publicación');
      }
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }
}