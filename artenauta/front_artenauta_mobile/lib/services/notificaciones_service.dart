import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';
import 'session_service.dart';

class NotificacionesService {
  static const String _keyUltimaVista = 'notif_ultima_vista';

  static Future<Map<String, String>> _headers() async {
    final token = await SessionService.getToken();
    return {
      ...ApiConfig.headers,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Guarda la fecha actual en UTC como última vista
  static Future<void> marcarComoVistas() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyUltimaVista,
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  /// Cuenta notificaciones nuevas desde la última visita
  static Future<int> contarNuevas() async {
    try {
      final todas = await getNotificaciones();
      final prefs = await SharedPreferences.getInstance();
      final ultimaVista = prefs.getString(_keyUltimaVista);

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

  /// GET: notificaciones del usuario logueado
  static Future<List<Map<String, dynamic>>> getNotificaciones() async {
    try {
      final usuario = await SessionService.getUsuario();
      final idUsuario = usuario?['id_usuario'];
      if (idUsuario == null) return [];

      final headers = await _headers();
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/notificaciones?id_usuario=$idUsuario'),
        headers: headers,
      );

      if (res.statusCode != 200) return [];
      return List<Map<String, dynamic>>.from(jsonDecode(res.body));
    } catch (e) {
      return [];
    }
  }

  /// GET: solicitudes pendientes (solo admin)
  static Future<List<Map<String, dynamic>>> getSolicitudes() async {
    try {
      final headers = await _headers();
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/notificaciones/solicitudes'),
        headers: headers,
      );

      if (res.statusCode != 200) return [];
      return List<Map<String, dynamic>>.from(jsonDecode(res.body));
    } catch (e) {
      return [];
    }
  }

  /// PATCH: aprobar solicitud
  static Future<bool> aprobarSolicitud(int idSolicitud) async {
    try {
      final usuario = await SessionService.getUsuario();
      final idUsuario = usuario?['id_usuario'];
      final headers = await _headers();

      final res = await http.patch(
        Uri.parse(
            '${ApiConfig.baseUrl}/notificaciones/solicitudes/$idSolicitud/aprobar'),
        headers: headers,
        body: jsonEncode({'id_usuario': idUsuario}),
      );

      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// PATCH: rechazar solicitud
  static Future<bool> rechazarSolicitud(int idSolicitud) async {
    try {
      final usuario = await SessionService.getUsuario();
      final idUsuario = usuario?['id_usuario'];
      final headers = await _headers();

      final res = await http.patch(
        Uri.parse(
            '${ApiConfig.baseUrl}/notificaciones/solicitudes/$idSolicitud/rechazar'),
        headers: headers,
        body: jsonEncode({'id_usuario': idUsuario}),
      );

      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}