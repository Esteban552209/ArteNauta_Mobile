import 'package:supabase_flutter/supabase_flutter.dart';

class ReaccionesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================================
  // DAR LIKE
  // ============================================================

  Future<void> darMeGusta({
    required int idPublicacion,
    required int idUsuario,
  }) async {
    try {
      await _supabase.from('reacciones').insert({
        'tipo': 'like',
        'id_usuario': idUsuario,
        'id_publicacion': idPublicacion,
      });
    } catch (e) {
      throw Exception('Error al dar Me Gusta: $e');
    }
  }

  // ============================================================
  // QUITAR LIKE
  // ============================================================

  Future<void> quitarMeGusta({
    required int idPublicacion,
    required int idUsuario,
  }) async {
    try {
      await _supabase
          .from('reacciones')
          .delete()
          .eq('id_usuario', idUsuario)
          .eq('id_publicacion', idPublicacion)
          .eq('tipo', 'like');
    } catch (e) {
      throw Exception('Error al quitar Me Gusta: $e');
    }
  }

  // ============================================================
  // COMPROBAR SI EL USUARIO YA DIO LIKE
  // ============================================================

  Future<bool> usuarioDioMeGusta({
    required int idPublicacion,
    required int idUsuario,
  }) async {
    try {
      final response = await _supabase
          .from('reacciones')
          .select('id_reaccion')
          .eq('id_usuario', idUsuario)
          .eq('id_publicacion', idPublicacion)
          .eq('tipo', 'like')
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception(
        'Error comprobando el Me Gusta: $e',
      );
    }
  }

  // ============================================================
  // OBTENER CANTIDAD DE LIKES
  // ============================================================

  Future<int> obtenerCantidadLikes({
    required int idPublicacion,
  }) async {
    try {
      final response = await _supabase
          .from('reacciones')
          .select('id_reaccion')
          .eq('id_publicacion', idPublicacion)
          .eq('tipo', 'like');

      return response.length;
    } catch (e) {
      throw Exception(
        'Error obteniendo los Me Gusta: $e',
      );
    }
  }
}