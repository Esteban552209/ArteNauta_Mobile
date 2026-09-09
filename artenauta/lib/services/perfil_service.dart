import 'package:supabase_flutter/supabase_flutter.dart';
import 'session_service.dart';

class PerfilService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================================
  // ACTUALIZAR PERFIL
  // ============================================================
  static Future<void> actualizarPerfil({
    required int idUsuario,
    required String nombre,
    required String apellido,
    required int? telefono,
  }) async {
    await _supabase
        .from('usuarios')
        .update({
          'nombre': nombre,
          'apellido': apellido,
          'telefono': telefono,
        })
        .eq('id_usuario', idUsuario);
  }

  // ============================================================
  // VERIFICAR SI YA TIENE SOLICITUD PENDIENTE
  // ============================================================
  static Future<bool> tieneSolicitudPendiente(int idUsuario) async {
    final existente = await _supabase
        .from('solicitudes')
        .select('id_solicitud')
        .eq('id_usuario', idUsuario)
        .eq('tipo_solicitud', 'artista')
        .eq('estado_solicitud', 'Pendiente')
        .maybeSingle();

    return existente != null;
  }

  // ============================================================
  // ENVIAR SOLICITUD DE ARTISTA + NOTIFICAR ADMINS
  // ============================================================
  static Future<void> enviarSolicitudArtista({
    required int idUsuario,
    required String nombreUsuario,
  }) async {
    // 1. Crear la solicitud
    await _supabase.from('solicitudes').insert({
      'id_usuario': idUsuario,
      'tipo_solicitud': 'artista',
      'estado_solicitud': 'Pendiente',
      'fecha_solicitud': DateTime.now().toUtc().toIso8601String(),
    });

    // 2. Obtener todos los admins
    final admins = await _supabase
        .from('usuarios')
        .select('id_usuario')
        .eq('id_rol', 3);

    // 3. Notificar a cada admin
    if ((admins as List).isNotEmpty) {
      final notifs = admins.map((a) => {
        'id_usuario': a['id_usuario'],
        'asunto': '$nombreUsuario quiere ser artista',
        'tipo_notificacion': 'Informativo',
        'fecha_notificacion': DateTime.now().toUtc().toIso8601String(),
      }).toList();

      await _supabase.from('notificaciones').insert(notifs);
    }
  }
}