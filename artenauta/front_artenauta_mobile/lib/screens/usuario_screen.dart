import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/session_service.dart';
import '../services/publicaciones_service.dart';
import '../services/notificaciones_service.dart';
import '../widgets/publicaciones/publicacion_card.dart';
import '../widgets/notificaciones/notificaciones_panel.dart';
import '../widgets/app_header.dart';
import '../widgets/app_menu.dart';
import '../screens/login_screen.dart';

class TestUsuarioScreen extends StatefulWidget {
  const TestUsuarioScreen({super.key});

  @override
  State<TestUsuarioScreen> createState() => _TestUsuarioScreenState();
}

class _TestUsuarioScreenState extends State<TestUsuarioScreen> {
  final PublicacionesService _publicacionesService = PublicacionesService();
  Map<String, dynamic>? _usuario;
  List<Map<String, dynamic>> _publicaciones = [];
  int _notifCount = 0;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final usuario = await SessionService.getUsuario();
      final count = await NotificacionesService.contarNuevas();
      final publicaciones = await _publicacionesService.obtenerPublicaciones();

      if (!mounted) return;
      setState(() {
        _usuario = usuario;
        _notifCount = count;
        _publicaciones = publicaciones;
        _cargando = false;
      });
    } catch (e) {
      debugPrint('Error cargando datos del usuario: $e');
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _abrirNotificaciones() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificacionesPanel()),
    );
    _actualizarNotificaciones();
  }

  Future<void> _actualizarNotificaciones() async {
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

  void _mostrarMenuOpciones(int idRol) {
    AppMenu.mostrar(
      context,
      idRol: idRol,
      notifCount: _notifCount,
      onNotificacionesTap: _abrirNotificaciones,
      onCerrarSesion: _cerrarSesion,
    );
  }

  @override
  Widget build(BuildContext context) {
    final nombre = _usuario?['nombre'] ?? 'Usuario';
    final idRol = int.tryParse(_usuario?['id_rol']?.toString() ?? '1') ?? 1;
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primaryCyan,
          onRefresh: () async {
            await _cargarDatos();
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Encabezado con el buscador activo
              SliverToBoxAdapter(
                child: AppHeader(
                  inicial: inicial,
                  notifCount: _notifCount,
                  onNotificacionesPressed: _abrirNotificaciones,
                  onAvatarPressed: () => _mostrarMenuOpciones(idRol),
                  publicaciones: _publicaciones,
                ),
              ),
              SliverToBoxAdapter(
                child: _HeaderUsuarioSection(nombre: nombre),
              ),
              if (_cargando)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryCyan),
                  ),
                )
              else if (_publicaciones.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No hay publicaciones disponibles en este momento.',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: PublicacionCard(publicacion: _publicaciones[index]),
                        );
                      },
                      childCount: _publicaciones.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      '© 2026 ArteNauta • Comunidad de Arte',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderUsuarioSection extends StatelessWidget {
  final String nombre;

  const _HeaderUsuarioSection({required this.nombre});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryCyan,
            AppTheme.primaryCyan.withValues(alpha: 0.82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryCyan.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Bienvenido, $nombre!',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Explora el talento de nuestra comunidad y apoya a tus artistas favoritos.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}