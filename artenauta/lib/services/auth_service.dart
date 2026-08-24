import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'session_service.dart'; // ← agregar este import

class AuthService {
  final String _supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final String _anonKey = dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '';

  Future<int> loginConEdgeFunction({
    required String email,
    required String clave,
  }) async {
    final url = Uri.parse('$_supabaseUrl/functions/v1/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_anonKey',
      },
      body: jsonEncode({
        'email': email,
        'password': clave,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(data['mensaje'] ?? data['error'] ?? 'Error de autenticación');
    }

    final String token = data['token'];
    final Map<String, dynamic> usuario = data['usuario'];
    final int idRol = usuario['id_rol'];

    debugPrint('Token recibido exitosamente: $token');

    // ── Guardar sesión ──────────────────────────
    await SessionService.guardar(
      token: token,
      usuario: usuario,
    );
    // ────────────────────────────────────────────

    return idRol;
  }

  // registrarUsuario queda exactamente igual
  Future<Map<String, dynamic>> registrarUsuario({
    required String nombre,
    required String apellido,
    required String telefono,
    required String email,
    required String clave,
  }) async {
    final url = Uri.parse('$_supabaseUrl/functions/v1/register');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_anonKey',
      },
      body: jsonEncode({
        'nombre': nombre,
        'apellido': apellido,
        'telefono': telefono,
        'email': email,
        'clave': clave,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(data['error'] ?? data['mensaje'] ?? 'Error al registrar');
    }

    return data;
  }
}