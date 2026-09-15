import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _keyToken = 'token';
  static const String _keyUsuario = 'usuario_data';

  // Guardar sesión completa (Token + Map del usuario)
  static Future<void> guardarSesion(String token, Map<String, dynamic> usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUsuario, jsonEncode(usuario));
  }

  // Comprobar si existe sesión activa
  static Future<bool> haySesion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyToken);
  }

  // Obtener el objeto completo del usuario en sesión
  static Future<Map<String, dynamic>?> getUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioString = prefs.getString(_keyUsuario);
    if (usuarioString != null) {
      return jsonDecode(usuarioString) as Map<String, dynamic>;
    }
    return null;
  }

  // Actualizar solo los datos del usuario en local (ej. tras editar perfil)
  static Future<void> guardarUsuario(Map<String, dynamic> usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsuario, jsonEncode(usuario));
  }

  // Obtener el ID del rol
  static Future<int?> getRol() async {
    final usuarioData = await getUsuario();
    if (usuarioData != null && usuarioData.containsKey('id_rol')) {
      return int.tryParse(usuarioData['id_rol'].toString());
    }
    return null;
  }

  // Obtener el JWT Token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // Cerrar sesión limpiando la memoria local
  static Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUsuario);
  }
}