import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/conversacion_model.dart';
import '../models/mensaje_model.dart';

class ConversacionesService {
  static final _client = Supabase.instance.client;

  // Lista de conversaciones del usuario logueado
  static Future<List<ConversacionModel>> getConversaciones(int idUsuario) async {
    final misParticipaciones = await _client
        .from('participantes')
        .select('id_conversacion')
        .eq('id_usuario', idUsuario);

    final idsConversaciones = (misParticipaciones as List)
        .map((e) => e['id_conversacion'] as int)
        .toList();

    if (idsConversaciones.isEmpty) return [];

    // El "otro" participante de cada conversación (no yo)
    final otros = await _client
        .from('participantes')
        .select('id_conversacion, usuarios(id_usuario, nombre, apellido, email)')
        .inFilter('id_conversacion', idsConversaciones)
        .neq('id_usuario', idUsuario);

    return (otros as List)
        .map((e) => ConversacionModel.fromParticipante(e as Map<String, dynamic>))
        .toList();
  }

  // Buscar usuarios por correo para iniciar una conversación nueva
  static Future<List<Map<String, dynamic>>> buscarUsuarioPorEmail(
    String query,
    int idUsuarioActual,
  ) async {
    if (query.trim().isEmpty) return [];
    final data = await _client
        .from('usuarios')
        .select('id_usuario, nombre, apellido, email')
        .ilike('email', '%$query%')
        .neq('id_usuario', idUsuarioActual)
        .limit(10);
    return List<Map<String, dynamic>>.from(data);
  }

  // Busca si ya existe una conversación entre dos usuarios
  static Future<int?> buscarConversacionExistente(
    int idUsuario1,
    int idUsuario2,
  ) async {
    final misConversaciones = await _client
        .from('participantes')
        .select('id_conversacion')
        .eq('id_usuario', idUsuario1);

    final ids = (misConversaciones as List)
        .map((e) => e['id_conversacion'] as int)
        .toList();

    if (ids.isEmpty) return null;

    final match = await _client
        .from('participantes')
        .select('id_conversacion')
        .inFilter('id_conversacion', ids)
        .eq('id_usuario', idUsuario2)
        .maybeSingle();

    return match?['id_conversacion'] as int?;
  }

  // Crea (o reutiliza) una conversación entre dos usuarios
  static Future<int> crearConversacion(int idUsuario1, int idUsuario2) async {
    final existente = await buscarConversacionExistente(idUsuario1, idUsuario2);
    if (existente != null) return existente;

    final nueva = await _client
        .from('conversaciones')
        .insert({'fecha_creacion': DateTime.now().toIso8601String()})
        .select('id_conversacion')
        .single();

    final idConversacion = nueva['id_conversacion'] as int;

    await _client.from('participantes').insert([
      {'id_conversacion': idConversacion, 'id_usuario': idUsuario1},
      {'id_conversacion': idConversacion, 'id_usuario': idUsuario2},
    ]);

    return idConversacion;
  }

  static Future<List<MensajeModel>> getMensajes(int idConversacion) async {
    final data = await _client
        .from('mensajes')
        .select()
        .eq('id_conversacion', idConversacion)
        .order('fecha_envio', ascending: true);

    return (data as List)
        .map((e) => MensajeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> enviarMensaje({
    required int idConversacion,
    required int idUsuario,
    required String contenido,
  }) async {
    await _client.from('mensajes').insert({
      'id_conversacion': idConversacion,
      'id_usuario': idUsuario,
      'contenido': contenido,
      'fecha_envio': DateTime.now().toIso8601String(),
    });
  }

  // Borra mensajes y participantes antes de la conversación (por si no hay ON DELETE CASCADE)
  static Future<void> eliminarConversacion(int idConversacion) async {
    await _client.from('mensajes').delete().eq('id_conversacion', idConversacion);
    await _client.from('participantes').delete().eq('id_conversacion', idConversacion);
    await _client.from('conversaciones').delete().eq('id_conversacion', idConversacion);
  }
}