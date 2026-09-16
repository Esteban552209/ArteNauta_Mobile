import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class CategoriasService {
  
  // GET: Obtener categorías (con búsqueda opcional)
  Future<List<dynamic>> getCategorias(String token, {String? buscar}) async {
    try {
      Uri url = Uri.parse('${ApiConfig.baseUrl}/categorias');
      
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
        throw Exception(data['error'] ?? 'Error desconocido al cargar categorías');
      }
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  // POST: Crear nueva categoría
  Future<void> crearCategoria({
    required String token,
    required String nombre,
    required String descripcion,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/categorias');

      final response = await http.post(
        url,
        headers: {
          ...ApiConfig.headers,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nombre_categoria': nombre,
          'descripcion': descripcion,
        }),
      );

      if (response.statusCode != 201) {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Error al crear categoría');
      }
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  // PATCH: Actualizar categoría existente
  Future<void> actualizarCategoria({
    required String token,
    required int idCategoria,
    required String nombre,
    required String descripcion,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/categorias/$idCategoria');

      final response = await http.patch(
        url,
        headers: {
          ...ApiConfig.headers,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nombre_categoria': nombre,
          'descripcion': descripcion,
        }),
      );

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Error al actualizar categoría');
      }
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }
}