import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart'; // Asegúrate de que la ruta sea correcta si están en la misma carpeta

class StatisticsService {
  Future<Map<String, dynamic>> fetchEstadisticas(String token) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/dashboard/estadisticas');
      
      final response = await http.get(
        url,
        headers: {
          ...ApiConfig.headers,
          'Authorization': 'Bearer $token', 
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}