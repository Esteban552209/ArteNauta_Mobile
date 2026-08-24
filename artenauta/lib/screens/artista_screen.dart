import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/session_service.dart';
import '../widgets/app_header.dart';
import '../widgets/app_menu.dart';
import '../widgets/gradient_header.dart';
import '../widgets/notificaciones_panel.dart';
import '../screens/perfil_screen.dart';
import '../screens/login_screen.dart';

class TestArtistaScreen extends StatefulWidget {
  const TestArtistaScreen({super.key});

  @override
  State<TestArtistaScreen> createState() => _TestArtistaScreenState();
}

class _TestArtistaScreenState extends State<TestArtistaScreen> {
  Map<String, dynamic>? _usuario;
  bool _menuAbierto = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final u = await SessionService.getUsuario();
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

  void _cerrarMenu() => setState(() => _menuAbierto = false);

  @override
  Widget build(BuildContext context) {
    final nombre = _usuario?['nombre'] ?? 'Usuario';
    final idRol = int.tryParse(_usuario?['id_rol'].toString() ?? '2') ?? 2;

    return Scaffold(
      body: GestureDetector(
        onTap: () { if (_menuAbierto) _cerrarMenu(); },
        child: Column(
          children: [
            // HEADER reutilizable
            AppHeader(
              idRol: idRol,
              nombre: nombre,
              menuAbierto: _menuAbierto,
              onMenuTap: () => setState(() => _menuAbierto = !_menuAbierto),
            ),

            // CONTENIDO
            Expanded(
              child: Stack(
                children: [
                  // Muro de publicaciones — tu compañero lo integrará aquí
                  Padding(
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

                  // MENÚ DESPLEGABLE
                  if (_menuAbierto)
                    Positioned(
                      top: 0,
                      right: 16,
                      child: AppMenu(
                        idRol: idRol,
                        onNuevaPublicacion: () {
                          _cerrarMenu();
                          // tu compañero conecta aquí
                        },
                        onMiPerfil: () {
                          _cerrarMenu();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PerfilScreen()),
                          );
                        },
                        onConversaciones: () {
                          _cerrarMenu();
                          // tu compañero conecta aquí
                        },
                        onNotificaciones: () {
                          _cerrarMenu();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotificacionesPanel()),
                          );
                        },
                        onCerrarSesion: _cerrarSesion,
                      ),
                    ),
                ],
              ),
            ),

            // FOOTER
            const GradientHeader(
              height: 50,
              child: Center(
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
      ),
    );
  }
}