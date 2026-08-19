import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/menu_drawer.dart';
import '../notificaciones/notificaciones_screen.dart';

class PanelArtistaScreen extends StatefulWidget {
  final String nombre;
  final int idRol;

  const PanelArtistaScreen({
    super.key,
    required this.nombre,
    required this.idRol,
  });

  @override
  State<PanelArtistaScreen> createState() => _PanelArtistaScreenState();
}

class _PanelArtistaScreenState extends State<PanelArtistaScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: MenuDrawer(
        idRol: widget.idRol,
        onNuevaPublicacion: () {
          // aquí va la pantalla de nueva publicación
        },
        onMiPerfil: () {
          // aquí va la pantalla de perfil
        },
        onNotificaciones: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NotificacionesScreen(),
            ),
          );
        },
        onCerrarSesion: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            GradientHeader(
              height: 100,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/LOGO.png', height: 80),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.idRol == 3
                                  ? 'Panel Admin'
                                  : widget.idRol == 2
                                      ? 'Panel Artista'
                                      : 'Panel Usuario',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Bienvenido, ${widget.nombre}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Botón Menú
                    ElevatedButton(
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.white54),
                        ),
                      ),
                      child: const Text('Menú'),
                    ),
                  ],
                ),
              ),
            ),

            // Contenido principal
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenido, ${widget.nombre}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tu espacio creativo en ArteNauta',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    // Aquí tu compañero integrará las publicaciones
                  ],
                ),
              ),
            ),

            // Footer
            GradientHeader(
              height: 50,
              child: const Center(
                child: Text(
                  '©2026 ArteNauta',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
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

// Placeholder para volver al home
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Home')),
    );
  }
}