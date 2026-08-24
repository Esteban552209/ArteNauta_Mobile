import 'dart:convert';
import '../services/session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _keyToken = 'token';
  static const _keyUsuario = 'usuario';

  // Guardar sesión después del login
  static Future<void> guardar({
    required String token,
    required Map<String, dynamic> usuario,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUsuario, jsonEncode(usuario));
  }

  // Obtener token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // Obtener usuario completo
  static Future<Map<String, dynamic>?> getUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUsuario);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  // Obtener solo el id_rol
  static Future<int?> getRol() async {
    final usuario = await getUsuario();
    if (usuario == null) return null;
    return int.tryParse(usuario['id_rol'].toString());
  }

  // Cerrar sesión
  static Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUsuario);
  }

  // Verificar si hay sesión activa
  static Future<bool> haySesion() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}