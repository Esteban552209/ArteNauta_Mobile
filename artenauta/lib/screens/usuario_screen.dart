import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/session_service.dart';
import '../services/publicaciones_service.dart';
import '../services/notificaciones_service.dart';
import '../widgets/app_header.dart';
import '../widgets/app_menu.dart';
import '../widgets/notificaciones/notificaciones_panel.dart';
import '../widgets/publicaciones/publicacion_card.dart';
import '../screens/login_screen.dart';

class UsuarioScreen extends StatefulWidget {
  const UsuarioScreen({super.key});

  @override
  State<UsuarioScreen> createState() => _UsuarioScreenState();
}

class _UsuarioScreenState extends State<UsuarioScreen> {
  final PublicacionesService _publicacionesService = PublicacionesService();

  Map<String, dynamic>? _usuario;
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

      if (!mounted) return;

      setState(() {
        _usuario = usuario;
        _notifCount = count;
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
            setState(() {});
            await _cargarDatos();
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Encabezado modular
              SliverToBoxAdapter(
                child: AppHeader(
                  inicial: inicial,
                  notifCount: _notifCount,
                  onNotificacionesPressed: _abrirNotificaciones,
                  onAvatarPressed: () => _mostrarMenuOpciones(idRol),
                ),
              ),

              // Banner de bienvenida
              SliverToBoxAdapter(
                child: _HeaderBienvenidaSection(nombre: nombre),
              ),

              // Listado de publicaciones
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _publicacionesService.obtenerPublicaciones(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting || _cargando) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(color: AppTheme.primaryCyan),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Error al cargar publicaciones:\n${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.redAccent, height: 1.4),
                          ),
                        ),
                      ),
                    );
                  }

                  final publicaciones = snapshot.data ?? [];
                  if (publicaciones.isEmpty) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'No hay publicaciones disponibles por el momento.',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: PublicacionCard(
                              publicacion: publicaciones[index],
                            ),
                          );
                        },
                        childCount: publicaciones.length,
                      ),
                    ),
                  );
                },
              ),

              // Pie de página
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      '© 2026 ArteNauta • Todos los derechos reservados',
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

class _HeaderBienvenidaSection extends StatelessWidget {
  final String nombre;

  const _HeaderBienvenidaSection({required this.nombre});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
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
              color: AppTheme.primaryCyan,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Explora y descubre el talento emergente en ArteNauta',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}