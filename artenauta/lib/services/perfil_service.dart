import 'package:supabase_flutter/supabase_flutter.dart';

class PerfilService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================================
  // OBTENER PERFIL
  // ============================================================

  static Future<Map<String, dynamic>> obtenerPerfil(
    int idUsuario,
  ) async {
    try {
      final response = await _supabase
          .from('usuarios')
          .select(
            'id_usuario, nombre, apellido, email, telefono, id_rol',
          )
          .eq('id_usuario', idUsuario)
          .single();

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Error al obtener el perfil: $e');
    }
  }

  // ============================================================
  // ACTUALIZAR PERFIL
  // ============================================================

  static Future<void> actualizarPerfil({
    required int idUsuario,
    required String nombre,
    required String apellido,
    required int? telefono,
  }) async {
    try {
      await _supabase
          .from('usuarios')
          .update({
            'nombre': nombre,
            'apellido': apellido,
            'telefono': telefono,
          })
          .eq('id_usuario', idUsuario);
    } catch (e) {
      throw Exception(
        'Error al actualizar el perfil: $e',
      );
    }
  }

  // ============================================================
  // VERIFICAR SOLICITUD PENDIENTE
  // ============================================================

  static Future<bool> tieneSolicitudPendiente(
    int idUsuario,
  ) async {
    try {
      final existente = await _supabase
          .from('solicitudes')
          .select('id_solicitud')
          .eq('id_usuario', idUsuario)
          .eq('tipo_solicitud', 'artista')
          .eq('estado_solicitud', 'Pendiente')
          .maybeSingle();

      return existente != null;
    } catch (e) {
      throw Exception(
        'Error al verificar la solicitud: $e',
      );
    }
  }

  // ============================================================
  // ENVIAR SOLICITUD DE ARTISTA
  // ============================================================

  static Future<void> enviarSolicitudArtista({
    required int idUsuario,
    required String nombreUsuario,
  }) async {
    try {
      // Primero evitamos solicitudes duplicadas.
      final pendiente =
          await tieneSolicitudPendiente(idUsuario);

      if (pendiente) {
        throw Exception(
          'Ya tienes una solicitud pendiente.',
        );
      }

      await _supabase.from('solicitudes').insert({
        'id_usuario': idUsuario,
        'tipo_solicitud': 'artista',
        'estado_solicitud': 'Pendiente',
        'fecha_solicitud':
            DateTime.now().toUtc().toIso8601String(),
      });

      // Buscar administradores.
      final admins = await _supabase
          .from('usuarios')
          .select('id_usuario')
          .eq('id_rol', 3);

      final listaAdmins =
          List<Map<String, dynamic>>.from(admins);

      if (listaAdmins.isNotEmpty) {
        final notificaciones = listaAdmins.map((admin) {
          return {
            'id_usuario': admin['id_usuario'],
            'asunto':
                '$nombreUsuario quiere ser artista',
            'tipo_notificacion': 'Informativo',
            'fecha_notificacion':
                DateTime.now()
                    .toUtc()
                    .toIso8601String(),
          };
        }).toList();

        await _supabase
            .from('notificaciones')
            .insert(notificaciones);
      }
    } catch (e) {
      throw Exception(
        'Error al enviar la solicitud: $e',
      );
    }
  }
}