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

  /// Obtener publicaciones creadas por un usuario específico
  static Future<List<Map<String, dynamic>>> getPublicacionesPorUsuario(int idUsuario) async {
    final response = await _supabase
        .from('publicaciones')
        .select('*, categorias(nombre_categoria)') // Si tienes relación con categorías
        .eq('id_usuario', idUsuario)
        .order('fecha_publicacion', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Editar información de una publicación
  static Future<void> editarPublicacion({
    required int idPublicacion,
    required String titulo,
    required String descripcion,
    double? precio,
  }) async {
    await _supabase.from('publicaciones').update({
      'titulo': titulo,
      'descripcion': descripcion,
      if (precio != null) 'precio': precio,
    }).eq('id_publicacion', idPublicacion);
  }

  /// Eliminar una publicación
  static Future<void> eliminarPublicacion(int idPublicacion) async {
    await _supabase
        .from('publicaciones')
        .delete()
        .eq('id_publicacion', idPublicacion);
  }
}