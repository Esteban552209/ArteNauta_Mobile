import 'package:supabase_flutter/supabase_flutter.dart';

class NotificacionesService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// GET: Obtener las notificaciones del usuario
  static Future<List<Map<String, dynamic>>> getNotificaciones() async {
    try {
      final response = await _supabase
          .from('notificaciones')
          .select('*')
          .order('fecha_notificacion', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  /// GET: Obtener las solicitudes pendientes (Admin)
  static Future<List<Map<String, dynamic>>> getSolicitudes() async {
    try {
      final response = await _supabase
          .from('solicitudes')
          .select('*, usuarios(nombre, apellido)')
          .eq('estado', 'pendiente')
          .order('fecha_solicitud', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  /// POST: Crear una nueva notificación
  static Future<bool> crearNotificacion({
    required int idUsuario,
    required String asunto,
    required String tipoNotificacion,
  }) async {
    try {
      await _supabase.from('notificaciones').insert({
        'id_usuario': idUsuario,
        'asunto': asunto,
        'tipo_notificacion': tipoNotificacion,
        'fecha_notificacion': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// PATCH: Aprobar una solicitud
  static Future<bool> aprobarSolicitud(int idSolicitud) async {
    try {
      await _supabase
          .from('solicitudes')
          .update({'estado': 'aprobada'})
          .eq('id_solicitud', idSolicitud);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// PATCH: Rechazar una solicitud
  static Future<bool> rechazarSolicitud(int idSolicitud) async {
    try {
      await _supabase
          .from('solicitudes')
          .update({'estado': 'rechazada'})
          .eq('id_solicitud', idSolicitud);
      return true;
    } catch (e) {
      return false;
    }
  }
}