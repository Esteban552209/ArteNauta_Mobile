import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';
import 'session_service.dart';

class NotificacionesService {
  static const String _keyUltimaVista = 'notif_ultima_vista';

  Future<Map<String, String>> _headers() async {
    final token = await SessionService.getToken();
    return {
      ...ApiConfig.headers,
      'Authorization': 'Bearer $token',
    };
  }

  // GET notificaciones del usuario
  Future<List<Map<String, dynamic>>> getNotificaciones() async {
    final usuario = await SessionService.getUsuario();
    final idUsuario = usuario?['id_usuario'];
    final url = Uri.parse('${ApiConfig.baseUrl}/notificaciones?id_usuario=$idUsuario');

    try {
      final response = await http.get(url, headers: await _headers());
      if (response.statusCode != 200) return [];
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } catch (e) {
      throw Exception('Error al obtener notificaciones: $e');
    }
  }

  // GET solicitudes pendientes (solo admin)
  Future<List<Map<String, dynamic>>> getSolicitudes() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/notificaciones/solicitudes');

    try {
      final response = await http.get(url, headers: await _headers());
      if (response.statusCode != 200) return [];
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } catch (e) {
      throw Exception('Error al obtener solicitudes: $e');
    }
  }

  // PATCH aprobar solicitud
  Future<void> aprobarSolicitud({
    required int idSolicitud,
    required int idUsuario,
  }) async {
    final url = Uri.parse(
        '${ApiConfig.baseUrl}/notificaciones/solicitudes/$idSolicitud/aprobar');

    try {
      final response = await http.patch(
        url,
        headers: await _headers(),
        body: jsonEncode({'id_usuario': idUsuario}),
      );
      if (response.statusCode != 200) {
        throw Exception('Error al aprobar solicitud');
      }
    } catch (e) {
      throw Exception('Error al aprobar solicitud: $e');
    }
  }

  // PATCH rechazar solicitud
  Future<void> rechazarSolicitud({
    required int idSolicitud,
    required int idUsuario,
  }) async {
    final url = Uri.parse(
        '${ApiConfig.baseUrl}/notificaciones/solicitudes/$idSolicitud/rechazar');

    try {
      final response = await http.patch(
        url,
        headers: await _headers(),
        body: jsonEncode({'id_usuario': idUsuario}),
      );
      if (response.statusCode != 200) {
        throw Exception('Error al rechazar solicitud');
      }
    } catch (e) {
      throw Exception('Error al rechazar solicitud: $e');
    }
  }

  // Contar notificaciones nuevas para el badge
  Future<int> contarNuevas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ultimaVista = prefs.getString(_keyUltimaVista);
      final todas = await getNotificaciones();

      if (ultimaVista == null) return todas.length;

      final fechaVista = DateTime.parse(ultimaVista);
      return todas.where((n) {
        final fecha = DateTime.tryParse(
            n['fecha_notificacion']?.toString() ?? '');
        return fecha != null && fecha.isAfter(fechaVista);
      }).length;
    } catch (e) {
      return 0;
    }
  }

  // Marcar como vistas
  Future<void> marcarComoVistas() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyUltimaVista,
      DateTime.now().toUtc().toIso8601String(),
    );
  }
}