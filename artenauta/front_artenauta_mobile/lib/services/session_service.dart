import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _keyToken = 'token';
  static const String _keyUsuario = 'usuario_data';

  static Future<void> guardarSesion(String token, Map<String, dynamic> usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUsuario, jsonEncode(usuario));
  }

  static Future<bool> haySesion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyToken);
  }

  static Future<int?> getRol() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioString = prefs.getString(_keyUsuario);
    if (usuarioString != null) {
      final usuarioData = jsonDecode(usuarioString);
      return usuarioData['id_rol'];
    }
    return null;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUsuario);
  }
}