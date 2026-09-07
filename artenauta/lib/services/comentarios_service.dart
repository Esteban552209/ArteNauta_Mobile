import 'package:supabase_flutter/supabase_flutter.dart';

class ComentariosService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================================
  // OBTENER COMENTARIOS
  // ============================================================

  Future<List<Map<String, dynamic>>> obtenerComentarios(
    int idPublicacion,
  ) async {
    try {
      final response = await _supabase
          .from('comentarios')
          .select('*')
          .eq('id_publicacion', idPublicacion)
          .order('fecha_comentario', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error al obtener comentarios: $e');
    }
  }

  // ============================================================
  // CREAR COMENTARIO
  // ============================================================

  Future<void> crearComentario({
    required int idPublicacion,
    required int idUsuario,
    required String contenido,
  }) async {
    try {
      await _supabase.from('comentarios').insert({
        'contenido': contenido,
        'id_publicacion': idPublicacion,
        'id_usuario_final': idUsuario,
      });

      // ── Notificar al artista ──────────────────────────────
      // 1. Obtener id_usuario_artista de la publicación
      final pub = await _supabase
          .from('publicaciones')
          .select('id_usuario_artista')
          .eq('id_publicacion', idPublicacion)
          .single();

      final idArtista = pub['id_usuario_artista'] as int?;

      // 2. No notificar si el artista se comentó a sí mismo
      if (idArtista != null && idArtista != idUsuario) {
        // 3. Obtener nombre del usuario que comentó
        final usuario = await _supabase
            .from('usuarios')
            .select('nombre')
            .eq('id_usuario', idUsuario)
            .single();

        final nombre = usuario['nombre'] ?? 'Alguien';

        // 4. Insertar notificación
        await _supabase.from('notificaciones').insert({
          'id_usuario': idArtista,
          'asunto': '$nombre comentó tu publicación',
          'tipo_notificacion': 'Comentario',
          'fecha_notificacion': DateTime.now().toUtc().toIso8601String(),
        });
      }
      // ─────────────────────────────────────────────────────
    } catch (e) {
      throw Exception('Error al crear comentario: $e');
    }
  }

  // ============================================================
  // ELIMINAR COMENTARIO
  // ============================================================

  Future<void> eliminarComentario(
    int idComentario,
  ) async {
    try {
      await _supabase
          .from('comentarios')
          .delete()
          .eq('id_comentario', idComentario);
    } catch (e) {
      throw Exception('Error al eliminar comentario: $e');
    }
  }
}