import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'session_service.dart';

class NotificacionesService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const String _keyUltimaVista = 'notif_ultima_vista';

  /// Guarda la fecha actual como última vez que se vieron las notificaciones
  static Future<void> marcarComoVistas() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyUltimaVista,
      DateTime.now().toUtc().toIso8601String()
    );
  }

  /// Obtiene cuántas notificaciones son nuevas desde la última vez que se abrió
  static Future<int> contarNuevas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ultimaVista = prefs.getString(_keyUltimaVista);

      final usuario = await SessionService.getUsuario();
      final idUsuario = usuario?['id_usuario'];
      if (idUsuario == null) return 0;

      var query = _supabase
          .from('notificaciones')
          .select('id_notificacion')
          .eq('id_usuario', idUsuario);

      // Si hay fecha guardada, solo cuenta las más nuevas
      if (ultimaVista != null) {
        query = query.gt('fecha_notificacion', ultimaVista);
      }

      final response = await query;
      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  /// GET: Obtener notificaciones del usuario logueado
  static Future<List<Map<String, dynamic>>> getNotificaciones() async {
    try {
      final usuario = await SessionService.getUsuario();
      final idUsuario = usuario?['id_usuario'];
      if (idUsuario == null) return [];

      final response = await _supabase
          .from('notificaciones')
          .select('*')
          .eq('id_usuario', idUsuario)
          .order('fecha_notificacion', ascending: false)
          .limit(20);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  /// GET: Obtener solicitudes pendientes (solo admin rol 3)
  static Future<List<Map<String, dynamic>>> getSolicitudes() async {
    try {
      final response = await _supabase
          .from('solicitudes')
          .select('*, usuarios(nombre, apellido)')
          .eq('tipo_solicitud', 'artista')
          .eq('estado_solicitud', 'Pendiente')
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
        'fecha_notificacion': DateTime.now().toUtc().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// PATCH: Aprobar solicitud + cambiar rol + notificar usuario
  static Future<bool> aprobarSolicitud(int idSolicitud) async {
    try {
      final sol = await _supabase
          .from('solicitudes')
          .select('id_usuario')
          .eq('id_solicitud', idSolicitud)
          .single();

      final idUsuario = sol['id_usuario'] as int;

      await _supabase
          .from('solicitudes')
          .update({'estado_solicitud': 'Aceptada'})
          .eq('id_solicitud', idSolicitud);

      await _supabase
          .from('usuarios')
          .update({'id_rol': 2})
          .eq('id_usuario', idUsuario);

      await _supabase.from('notificaciones').insert({
        'id_usuario': idUsuario,
        'asunto': '¡Tu solicitud para ser artista fue aprobada!',
        'tipo_notificacion': 'solicitud_aprobada',
        'fecha_notificacion': DateTime.now().toUtc().toIso8601String(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  /// PATCH: Rechazar solicitud + notificar usuario
  static Future<bool> rechazarSolicitud(int idSolicitud) async {
    try {
      final sol = await _supabase
          .from('solicitudes')
          .select('id_usuario')
          .eq('id_solicitud', idSolicitud)
          .single();

      final idUsuario = sol['id_usuario'] as int;

      await _supabase
          .from('solicitudes')
          .update({'estado_solicitud': 'Rechazada'})
          .eq('id_solicitud', idSolicitud);

      await _supabase.from('notificaciones').insert({
        'id_usuario': idUsuario,
        'asunto': 'Tu solicitud para ser artista no fue aprobada.',
        'tipo_notificacion': 'solicitud_rechazada',
        'fecha_notificacion': DateTime.now().toUtc().toIso8601String(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}