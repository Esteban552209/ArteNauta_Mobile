import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../models/notificacion_model.dart';

class NotificacionService {
  // GET — obtener notificaciones del usuario
  static Future<List<NotificacionModel>> obtener(
      int idUsuario, String token) async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.notificaciones}?id_usuario=$idUsuario'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((e) => NotificacionModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo notificaciones: $e');
      return [];
    }
  }

  // PATCH — marcar todas como leídas
  static Future<void> marcarTodasLeidas(String token) async {
    try {
      await http.patch(
        Uri.parse(ApiConstants.marcarLeidas),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      print('Error marcando leídas: $e');
    }
  }

  // PATCH — aprobar solicitud
  static Future<bool> aprobarSolicitud(
      int idSolicitud, int idUsuario, String token) async {
    try {
      final res = await http.patch(
        Uri.parse('${ApiConstants.aprobarSolicitud}/$idSolicitud/aprobar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'id_usuario': idUsuario}),
      );
      return res.statusCode == 200;
    } catch (e) {
      print('Error aprobando solicitud: $e');
      return false;
    }
  }

  // PATCH — rechazar solicitud
  static Future<bool> rechazarSolicitud(
      int idSolicitud, int idUsuario, String token) async {
    try {
      final res = await http.patch(
        Uri.parse('${ApiConstants.rechazarSolicitud}/$idSolicitud/rechazar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'id_usuario': idUsuario}),
      );
      return res.statusCode == 200;
    } catch (e) {
      print('Error rechazando solicitud: $e');
      return false;
    }
  }
}