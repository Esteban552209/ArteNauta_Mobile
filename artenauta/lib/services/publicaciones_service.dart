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
}