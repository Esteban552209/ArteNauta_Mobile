import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/gradient_header.dart';
import '../../services/session_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {

  int _totalUsuarios = 0;
  int _totalArtistas = 0;
  int _totalObras = 0;
  int _totalComentarios = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    try {
      final String? token = await SessionService.getToken();
      
      if (token == null) throw Exception('No hay sesión activa');

      final String baseUrl = dotenv.env['SUPABASE_URL']!; 
      final url = Uri.parse('$baseUrl/functions/v1/estadisticas');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', 
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['error'] ?? data['mensaje'] ?? 'Error al cargar datos HTTP ${response.statusCode}');
      }

      if (mounted) {
        setState(() {
          _totalUsuarios = data['totalUsuarios'] ?? 0;
          _totalArtistas = data['totalArtistas'] ?? 0;
          _totalObras = data['totalPublicaciones'] ?? 0;
          _totalComentarios = data['totalComentarios'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error real en petición a la API: $e");
      
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar las estadísticas')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GradientHeader(
            height: 120,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/LOGO.png',
                      height: 75, 
                      fit: BoxFit.contain,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.more_horiz, color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _cargarEstadisticas,
                    child: ListView(
                      padding: const EdgeInsets.all(24.0),
                      children: [
                        const Text(
                          'Bienvenido\nde vuelta!\nAdmin',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryCyan, 
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 30),

                        _buildStatCard('Usuarios en Total', _totalUsuarios, const Color(0xFF00BCD4)),
                        _buildStatCard('Artistas Verificados', _totalArtistas, const Color(0xFF673AB7)),
                        _buildStatCard('Obras Publicadas', _totalObras, const Color(0xFF4CAF50)),
                        _buildStatCard('Comentarios', _totalComentarios, const Color(0xFFFFC107)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String titulo, int cantidad, Color colorBorde) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: colorBorde,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      cantidad.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorBorde,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}