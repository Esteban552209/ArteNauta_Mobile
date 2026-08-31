import 'package:supabase_flutter/supabase_flutter.dart';

class ComentariosService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get: obtener y mostar los comentarios

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
      throw Exception(
        'Error al obtener comentarios: $e',
      );
    }
  }

  // Path: Subir comentarios

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
    } catch (e) {
      throw Exception(
        'Error al crear comentario: $e',
      );
    }
  }

  // Delete: Eliminar comentarios 

  Future<void> eliminarComentario(
    int idComentario,
  ) async {
    try {
      await _supabase
          .from('comentarios')
          .delete()
          .eq('id_comentario', idComentario);
    } catch (e) {
      throw Exception(
        'Error al eliminar comentario: $e',
      );
    }
  }
}