import 'package:supabase_flutter/supabase_flutter.dart';

class ReaccionesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Path: subir like a una publicacion

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

  // Delete. Eliminar el like de una publicacion

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

  // verificar si un usuario dio like a una publicacion

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

  // contar el total de likes por publicacion

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