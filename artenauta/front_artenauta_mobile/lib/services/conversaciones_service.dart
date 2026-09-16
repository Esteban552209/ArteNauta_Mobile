import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../models/conversacion_model.dart';
import '../models/mensaje_model.dart';

class ConversacionesService {
  // Lista de conversaciones del usuario logueado
  static Future<List<ConversacionModel>> getConversaciones(int idUsuario) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/conversaciones/usuario/$idUsuario');
    final response = await http.get(url, headers: await ApiConfig.headersConToken());

    if (response.statusCode != 200) {
      throw Exception('Error al cargar conversaciones: ${response.body}');
    }

    final data = jsonDecode(response.body) as List;
    return data
        .map((e) => ConversacionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Buscar usuario exacto por correo (según lo que soporta el backend hoy)
  static Future<List<Map<String, dynamic>>> buscarUsuarioPorEmail(
    String query,
    int idUsuarioActual,
  ) async {
    if (query.trim().isEmpty) return [];
    final url = Uri.parse('${ApiConfig.baseUrl}/usuarios/buscar?email=$query');
    final response = await http.get(url, headers: await ApiConfig.headersConToken());

    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body);
    if (data == null) return [];
    final usuario = data as Map<String, dynamic>;
    if (usuario['id_usuario'] == idUsuarioActual) return [];
    return [usuario];
  }

  // Crea (o reutiliza) una conversación entre dos usuarios
  static Future<int> crearConversacion(int idUsuario1, int idUsuario2) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/conversaciones');
    final response = await http.post(
      url,
      headers: await ApiConfig.headersConToken(),
      body: jsonEncode({'id_usuario_1': idUsuario1, 'id_usuario_2': idUsuario2}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al crear conversación: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['id_conversacion'] as int;
  }

  // Trae los mensajes de una conversación (excluye ocultos-para-mí)
  static Future<List<MensajeModel>> getMensajes(int idConversacion, int miId) async {
    final url = Uri.parse(
        '${ApiConfig.baseUrl}/mensajes/$idConversacion?id_usuario=$miId');
    final response = await http.get(url, headers: await ApiConfig.headersConToken());

    if (response.statusCode != 200) {
      throw Exception('Error al cargar mensajes: ${response.body}');
    }

    final data = jsonDecode(response.body) as List;
    return data
        .map((e) => MensajeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> enviarMensaje({
    required int idConversacion,
    required int idUsuario,
    required String contenido,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/mensajes');
    final response = await http.post(
      url,
      headers: await ApiConfig.headersConToken(),
      body: jsonEncode({
        'id_conversacion': idConversacion,
        'id_usuario': idUsuario,
        'contenido': contenido,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al enviar mensaje: ${response.body}');
    }
  }

  // Marca como leídos los mensajes del otro en esta conversación
  static Future<void> marcarComoLeidos(int idConversacion, int miId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/mensajes/leidos');
    await http.patch(
      url,
      headers: await ApiConfig.headersConToken(),
      body: jsonEncode({'id_conversacion': idConversacion, 'id_usuario': miId}),
    );
  }

  // Eliminar mensaje solo para mí
  static Future<void> eliminarMensajeParaMi(int idMensaje, int miId) async {
    final url = Uri.parse(
        '${ApiConfig.baseUrl}/mensajes/$idMensaje?modo=mi&id_usuario=$miId');
    await http.delete(url, headers: await ApiConfig.headersConToken());
  }

  // Eliminar mensaje para todos
  static Future<void> eliminarMensajeParaTodos(int idMensaje) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/mensajes/$idMensaje?modo=todos');
    await http.delete(url, headers: await ApiConfig.headersConToken());
  }

  // Eliminar conversación completa
  static Future<void> eliminarConversacion(int idConversacion) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/conversaciones/$idConversacion');
    await http.delete(url, headers: await ApiConfig.headersConToken());
  }
}