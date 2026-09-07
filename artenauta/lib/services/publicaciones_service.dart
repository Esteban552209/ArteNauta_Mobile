import 'package:supabase_flutter/supabase_flutter.dart';
import 'session_service.dart';

class PublicacionesService {
  static final SupabaseClient _supabase = Supabase.instance.client;

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

  /// Carga todas las categorías disponibles en la base de datos
   static Future<List<Map<String, dynamic>>> obtenerCategorias() async {
    try {
      final response = await _supabase
          .from('categorias')
          .select('id_categoria, nombre_categoria')
          .order('id_categoria', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error al obtener categorías: $e');
    }
  }

  /// Crea una nueva publicación asignada al usuario logueado
  static Future<void> crearPublicacion({
    required String titulo,
    required String descripcion,
    required String imagenUrl,
    required int idCategoria,
  }) async {
    try {
      final usuario = await SessionService.getUsuario();
      final idUsuario = usuario?['id_usuario'];

      if (idUsuario == null) {
        throw Exception('No se encontró una sesión activa de usuario.');
      }

      await _supabase.from('publicaciones').insert({
        'titulo': titulo,
        'descripcion': descripcion,
        'contenido': imagenUrl,
        'id_categoria': idCategoria,
        'id_usuario_artista': idUsuario,
        'estado': true,
        'fecha_publicacion': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error al registrar la publicación: $e');
    }
  }
}