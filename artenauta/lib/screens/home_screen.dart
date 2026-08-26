import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/gradient_header.dart';
import '../widgets/notificaciones_panel.dart';
import '../services/session_service.dart';
import '../screens/login_screen.dart';
import '../screens/perfil_screen.dart';
<<<<<<< HEAD
import '../screens/conversaciones_screen.dart';
=======
import 'admin/admin_users_screen.dart';
>>>>>>> master

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _usuario;
  bool _menuAbierto = false;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final u = await SessionService.getUsuario();
    print('Usuario guardado: $u');
    setState(() => _usuario = u);
  }

  Future<void> _cerrarSesion() async {
    await SessionService.cerrarSesion();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _abrirNotificaciones() {
    setState(() => _menuAbierto = false);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificacionesPanel()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nombre = _usuario?['nombre'] ?? 'Usuario';

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminUsersScreen()),
          );
        },
        backgroundColor:
            Colors.orange,
        icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
        label: const Text(
          'Test Admin',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // HEADER
                GradientHeader(
                  height: 100,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/LOGO.png',
                              height: 80,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Panel Artista',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Bienvenido, $nombre',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() => _menuAbierto = !_menuAbierto);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _menuAbierto
                                ? Colors.white
                                : AppTheme.primaryCyan,
                            foregroundColor: _menuAbierto
                                ? AppTheme.primaryCyan
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Menú'),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenido, $nombre',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryCyan,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tu espacio creativo en ArteNauta',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),

                // FOOTER
                GradientHeader(
                  height: 50,
                  child: const Center(
                    child: Text(
                      '©2026 ArteNauta',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // MENÚ DESPLEGABLE
            if (_menuAbierto)
              Positioned(
                top: 100,
                right: 16,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _itemMenu(
                          icon: Icons.add_circle_outline,
                          label: 'Nueva Publicación',
                          color: AppTheme.primaryCyan,
                          onTap: () {
                            setState(() => _menuAbierto = false);
                            // navegar a nueva publicación
                          },
                        ),
                        const Divider(height: 1),

                        _itemMenu(
                          icon: Icons.chat_bubble_outline,
                          label: 'Conversaciones',
                          color: AppTheme.primaryCyan,
                          onTap: () {
                            setState(() => _menuAbierto = false);
                            Navigator.push(
                            context,
                          MaterialPageRoute(builder: (_) => const ConversacionesScreen()),
                          );
                          },
                          ),
                        const Divider(height: 1),
                        
                        // INTEGRACIÓN DE MI PERFIL AQUÍ
                        _itemMenu(
                          icon: Icons.person_outline,
                          label: 'Mi Perfil',
                          color: AppTheme.primaryCyan,
                          onTap: () {
                            setState(() => _menuAbierto = false);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PerfilScreen(),
                              ),
                            );
                          },
                        ),
                        
                        const Divider(height: 1),
                        _itemMenu(
                          icon: Icons.notifications_outlined,
                          label: 'Notificaciones',
                          color: AppTheme.primaryCyan,
                          onTap: _abrirNotificaciones,
                        ),
                        const Divider(height: 1),
                        _itemMenu(
                          icon: Icons.logout,
                          label: 'Cerrar Sesión',
                          color: Colors.red,
                          onTap: _cerrarSesion,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _itemMenu({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color == Colors.red ? Colors.red : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
