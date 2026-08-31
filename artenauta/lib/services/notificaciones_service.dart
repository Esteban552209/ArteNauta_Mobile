import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_service.dart';

class NotificacionesService {
  static const String _api = 'http://10.0.2.2:3000'; 

  // GET notificaciones del usuario
  static Future<List<Map<String, dynamic>>> getNotificaciones() async {
    final token = await SessionService.getToken();
    final usuario = await SessionService.getUsuario();
    final idUsuario = usuario?['id_usuario'];

    if (token == null || idUsuario == null) return [];

    final res = await http.get(
      Uri.parse('$_api/notificaciones?id_usuario=$idUsuario'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) return [];
    final data = jsonDecode(res.body) as List;
    return data.cast<Map<String, dynamic>>();
  }

  // GET solicitudes pendientes (solo admin rol 3)
  static Future<List<Map<String, dynamic>>> getSolicitudes() async {
    final token = await SessionService.getToken();
    if (token == null) return [];

    final res = await http.get(
      Uri.parse('$_api/notificaciones/solicitudes'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) return [];
    final data = jsonDecode(res.body) as List;
    return data.cast<Map<String, dynamic>>();
  }

  // PATCH aprobar solicitud
  static Future<bool> aprobarSolicitud(int idSolicitud) async {
    final token = await SessionService.getToken();
    if (token == null) return false;

    final res = await http.patch(
      Uri.parse('$_api/notificaciones/solicitudes/$idSolicitud/aprobar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return res.statusCode == 200;
  }

  // PATCH rechazar solicitud
  static Future<bool> rechazarSolicitud(int idSolicitud) async {
    final token = await SessionService.getToken();
    if (token == null) return false;

    final res = await http.patch(
      Uri.parse('$_api/notificaciones/solicitudes/$idSolicitud/rechazar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return res.statusCode == 200;
  }
}