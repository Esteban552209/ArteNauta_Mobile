import 'package:http/http.dart' as http;
import 'session_service.dart';

class ApiConfig {
  static const List<String> _posiblesIPs = [
    'http://10.1.202.228:3000/mobile',
    // 'http://192.168.1.50:3000/mobile',
    // 'http://192.168.0.12:3000/mobile',
    // 'http://10.0.2.2:3000/mobile',
    // 'http://localhost:3000/mobile',
  ];

  static String _baseUrlActiva = _posiblesIPs.first;
  static String get baseUrl => _baseUrlActiva;
  static Future<String> detectarBaseUrlActiva() async {
    for (final url in _posiblesIPs) {
      try {
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(milliseconds: 1200));

        if (response.statusCode < 500) {
          _baseUrlActiva = url;
          return _baseUrlActiva;
        }
      } catch (_) {
      }
    }
    return _baseUrlActiva;
  }

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Future<Map<String, String>> headersConToken() async {
    final token = await SessionService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}