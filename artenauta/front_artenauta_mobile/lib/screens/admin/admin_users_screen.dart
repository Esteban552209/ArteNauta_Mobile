import 'package:flutter/material.dart';
import '../../services/admin/statistics_service.dart';
import '../../services/session_service.dart'; 
import '../../core/theme/app_theme.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/admin_drawer.dart';

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

  final StatisticsService _statisticsService = StatisticsService();

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    try {
      setState(() {
        _isLoading = true;
      });

      String? tokenActual = await SessionService.getToken(); 

      if (tokenActual == null || tokenActual.isEmpty) {
        throw Exception('No hay sesión activa. Falta el token.');
      }

      final data = await _statisticsService.fetchEstadisticas(tokenActual);

      setState(() {
        _totalUsuarios = data['totalUsuarios'] ?? 0;
        _totalArtistas = data['totalArtistas'] ?? 0;
        _totalObras = data['totalPublicaciones'] ?? 0; 
        _totalComentarios = data['totalComentarios'] ?? 0;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: const AdminDrawer(),
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
                      child: Builder(
                        builder: (context) {
                          return IconButton(
                            icon: const Icon(
                              Icons.more_horiz,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Scaffold.of(context).openEndDrawer();
                            },
                          );
                        },
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

                        _buildStatCard(
                          'Usuarios en Total',
                          _totalUsuarios,
                          const Color(0xFF00BCD4),
                        ),
                        _buildStatCard(
                          'Artistas Verificados',
                          _totalArtistas,
                          const Color(0xFF673AB7),
                        ),
                        _buildStatCard(
                          'Obras Publicadas',
                          _totalObras,
                          const Color(0xFF4CAF50),
                        ),
                        _buildStatCard(
                          'Comentarios',
                          _totalComentarios,
                          const Color(0xFFFFC107),
                        ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
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
