import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/conversacion_model.dart';
import '../models/mensaje_model.dart';

class ConversacionesService {
  static final _client = Supabase.instance.client;

  // Lista de conversaciones del usuario logueado, con último mensaje y no leídos
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

    // Todos los mensajes de esas conversaciones, más recientes primero
    final mensajes = await _client
        .from('mensajes')
        .select('id_conversacion, contenido, fecha_envio, id_usuario, leido')
        .inFilter('id_conversacion', idsConversaciones)
        .order('fecha_envio', ascending: false);

    final ultimoPorConversacion = <int, Map<String, dynamic>>{};
    final noLeidosPorConversacion = <int, int>{};

    for (final m in (mensajes as List)) {
      final idConv = m['id_conversacion'] as int;

      // El primero que aparece por conversación (orden descendente) es el más reciente
      ultimoPorConversacion.putIfAbsent(idConv, () => m as Map<String, dynamic>);

      final esDeOtro = m['id_usuario'] != idUsuario;
      final noLeido = m['leido'] == false;
      if (esDeOtro && noLeido) {
        noLeidosPorConversacion[idConv] = (noLeidosPorConversacion[idConv] ?? 0) + 1;
      }
    }

    final lista = (otros as List).map((e) {
      final map = e as Map<String, dynamic>;
      final idConv = map['id_conversacion'] as int;
      final ultimo = ultimoPorConversacion[idConv];
      return ConversacionModel.fromParticipante(
        map,
        ultimoMensaje: ultimo?['contenido'] as String?,
        fechaUltimoMensaje:
            ultimo != null ? DateTime.parse(ultimo['fecha_envio']) : null,
        noLeidos: noLeidosPorConversacion[idConv] ?? 0,
      );
    }).toList();

    // Las más recientes primero, igual que WhatsApp
    lista.sort((a, b) {
      if (a.fechaUltimoMensaje == null) return 1;
      if (b.fechaUltimoMensaje == null) return -1;
      return b.fechaUltimoMensaje!.compareTo(a.fechaUltimoMensaje!);
    });

    return lista;
  }

  // Marca como leídos todos los mensajes de la otra persona en esta conversación
  static Future<void> marcarComoLeidos(int idConversacion, int miId) async {
    await _client
        .from('mensajes')
        .update({'leido': true})
        .eq('id_conversacion', idConversacion)
        .neq('id_usuario', miId)
        .eq('leido', false);
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
      'leido': false,
    });
  }

  // Borra mensajes y participantes antes de la conversación (por si no hay ON DELETE CASCADE)
  static Future<void> eliminarConversacion(int idConversacion) async {
    await _client.from('mensajes').delete().eq('id_conversacion', idConversacion);
    await _client.from('participantes').delete().eq('id_conversacion', idConversacion);
    await _client.from('conversaciones').delete().eq('id_conversacion', idConversacion);
  }
}