import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class UsuariosService {
  
  // GET: Obtener y filtrar usuarios
  Future<List<dynamic>> getUsuarios(String token, {String? buscar, String? estado, String? rol}) async {
    try {
      Uri url = Uri.parse('${ApiConfig.baseUrl}/usuarios');
      Map<String, String> queryParams = {};
      
      if (buscar != null && buscar.isNotEmpty) queryParams['buscar'] = buscar;
      if (estado != null) queryParams['estado'] = estado;
      if (rol != null) queryParams['rol'] = rol;

      if (queryParams.isNotEmpty) {
        url = url.replace(queryParameters: queryParams);
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
        throw Exception(data['error'] ?? 'Error desconocido al cargar usuarios');
      }
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  // PATCH: Actualizar un usuario
  Future<void> actualizarUsuario({
    required String token,
    required int idUsuario,
    required String nombre,
    required String apellido,
    required int idRol,
    required bool estado,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/usuarios/$idUsuario');

      final response = await http.patch(
        url,
        headers: {
          ...ApiConfig.headers,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nombre': nombre,
          'apellido': apellido,
          'id_rol': idRol,
          'estado_cuenta': estado,
        }),
      );

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Error al actualizar usuario');
      }
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }
}