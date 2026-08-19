import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String _supabaseUrl = 'https://oqvuiosndsxjqelefokc.supabase.co';
  final String _anonKey = 'sb_publishable_3Vc1WhpZiW1x_R8VP1fOsw_C_uSsSIp';

//login
  Future<Map<String, dynamic>> loginConEdgeFunction({
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
        'clave': clave,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Error ${response.statusCode}: Bad Request');
    }

    return data;
  }

  
//Registro

Future<Map<String, dynamic>> registrarUsuario({
  required String nombre,
  required String apellido,
  required String telefono,
  required String email,
  required String clave,
}) async {

  final url = Uri.parse(
    '$_supabaseUrl/functions/v1/register',
  );

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

  final data =
      jsonDecode(response.body) as Map<String, dynamic>;

  if (response.statusCode != 200) {
    throw Exception(
      data['error'] ??
          'Error ${response.statusCode}',
    );
  }

  return data;
}
}
