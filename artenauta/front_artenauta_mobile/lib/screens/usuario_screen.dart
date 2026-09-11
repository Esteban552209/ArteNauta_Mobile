import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/session_service.dart';
import '../services/publicaciones_service.dart';
import '../services/notificaciones_service.dart';
import '../widgets/app_header.dart';
import '../widgets/app_menu.dart';
import '../widgets/gradient_header.dart';
import '../widgets/notificaciones/notificaciones_panel.dart';
import '../widgets/publicaciones/publicacion_card.dart';
import '../screens/perfil_screen.dart';
import '../screens/login_screen.dart';
import '../screens/conversaciones_screen.dart';

class UsuarioScreen extends StatefulWidget {
  const UsuarioScreen({super.key});

  @override
  State<UsuarioScreen> createState() => _UsuarioScreenState();
}

class _UsuarioScreenState extends State<UsuarioScreen> {
  final PublicacionesService _publicacionesService = PublicacionesService();

  Map<String, dynamic>? _usuario;
  bool _menuAbierto = false;
  int _notifCount = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // ============================================================
  // CARGAR USUARIO Y NOTIFICACIONES
  // ============================================================

  Future<void> _cargarDatos() async {
    try {
      final usuario = await SessionService.getUsuario();
      final count = await NotificacionesService.contarNuevas();

      if (!mounted) return;

      setState(() {
        _usuario = usuario;
        _notifCount = count;
      });
    } catch (e) {
      debugPrint('Error cargando datos del usuario: $e');
    }
  }

  Future<void> _abrirNotificaciones() async {
    _cerrarMenu();

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificacionesPanel()),
    );

    try {
      final count = await NotificacionesService.contarNuevas();
      if (!mounted) return;
      setState(() => _notifCount = count);
    } catch (e) {
      debugPrint('Error actualizando notificaciones: $e');
    }
  }

  Future<void> _cerrarSesion() async {
    await SessionService.cerrarSesion();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _cerrarMenu() {
    if (_menuAbierto) {
      setState(() => _menuAbierto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = _usuario?['nombre'] ?? 'Usuario';
    final idRol =
        int.tryParse(_usuario?['id_rol']?.toString() ?? '1') ?? 1;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // CONTENIDO NORMAL (header, feed, footer)
            Column(
              children: [
                AppHeader(
                  idRol: idRol,
                  nombre: nombre,
                  menuAbierto: _menuAbierto,
                  notifCount: _notifCount,
                  onMenuTap: () =>
                      setState(() => _menuAbierto = !_menuAbierto),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
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
                              'Explora y descubre arte en ArteNauta',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: _publicacionesService.obtenerPublicaciones(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.primaryCyan,
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                    'Error al cargar publicaciones:\n${snapshot.error}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              );
                            }
                            final publicaciones = snapshot.data ?? [];
                            if (publicaciones.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No hay publicaciones disponibles por el momento.',
                                ),
                              );
                            }
                            return RefreshIndicator(
                              onRefresh: () async {
                                setState(() {});
                              },
                              child: ListView.builder(
                                padding: const EdgeInsets.all(12.0),
                                itemCount: publicaciones.length,
                                itemBuilder: (context, index) {
                                  return PublicacionCard(
                                    publicacion: publicaciones[index],
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const GradientHeader(
                  height: 40,
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

            // BARRERA INVISIBLE: cierra el menú al tocar fuera de él
            if (_menuAbierto)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _cerrarMenu,
                ),
              ),

            // MENÚ (va DESPUÉS de la barrera → queda encima y recibe el tap primero)
            if (_menuAbierto)
              Positioned(
                top: 0,
                right: 16,
                child: AppMenu(
                  idRol: idRol,
                  notifCount: _notifCount,
                  onMiPerfil: () {
                    _cerrarMenu();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PerfilScreen()),
                    );
                  },
                  onConversaciones: () {
                    _cerrarMenu();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ConversacionesScreen(),
                      ),
                    );
                  },
                  onNotificaciones: _abrirNotificaciones,
                  onCerrarSesion: _cerrarSesion,
                ),
              ),
          ],
        ),
      ),
    );
  }
}