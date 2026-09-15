import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class ComentariosService {
  
  // GET: Obtener todos los comentarios (Endpoint para el Admin)
  Future<List<dynamic>> getComentariosAdmin(String token) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/admin/comentarios');

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
        throw Exception(data['error'] ?? 'Error desconocido al cargar comentarios');
      }
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  // DELETE: Eliminar un comentario específico por su ID
  Future<void> eliminarComentario({
    required String token,
    required int idComentario,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/comentarios/$idComentario');

      final response = await http.delete(
        url,
        headers: {
          ...ApiConfig.headers,
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Error al eliminar comentario');
      }
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }
}