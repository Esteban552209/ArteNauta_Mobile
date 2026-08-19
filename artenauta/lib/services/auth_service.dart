import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
import '../models/usuario_model.dart';

class AuthService {
  // Guardar sesión en el dispositivo
  static Future<void> guardarSesion(UsuarioModel usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', usuario.token);
    await prefs.setInt('id_usuario', usuario.idUsuario);
    await prefs.setString('nombre', usuario.nombre);
    await prefs.setInt('id_rol', usuario.idRol);
  }

  // Obtener token guardado
  static Future<String?> obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Obtener id_usuario guardado
  static Future<int?> obtenerIdUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id_usuario');
  }

  // Obtener id_rol guardado
  static Future<int?> obtenerIdRol() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id_rol');
  }

  // Cerrar sesión
  static Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Login
  static Future<UsuarioModel?> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'clave': password}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final token = data['token'] ?? '';
        final usuario = UsuarioModel.fromJson(data['usuario'] ?? data, token);
        await guardarSesion(usuario);
        return usuario;
      }
      return null;
    } catch (e) {
      print('Error en login: $e');
      return null;
    }
  }
}