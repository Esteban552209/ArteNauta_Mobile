import 'package:supabase_flutter/supabase_flutter.dart';

class PublicacionesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // GET: Obtener todas las publicaciones activas
  Future<List<Map<String, dynamic>>> obtenerPublicaciones() async {
    try {
      final response = await _supabase
          .from('publicaciones')
          .select('*')
          .eq('estado', true)
          .order('fecha_publicacion', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error al obtener publicaciones: $e');
    }
  }

  // Dar Me Gusta a una publicación 
  Future<void> darMeGusta(int idPublicacion, int idUsuario) async {
    await _supabase.from('likes').insert({
      'id_publicacion': idPublicacion,
      'id_usuario': idUsuario,
    });
  }

  // Crear una nueva publicación 
  Future<void> crearPublicacion(Map<String, dynamic> datosPublicacion) async {
    await _supabase.from('publicaciones').insert(datosPublicacion);
  }
}