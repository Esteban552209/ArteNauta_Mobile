import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/session_service.dart';
import '../services/publicaciones_service.dart';
import '../services/notificaciones_service.dart';
import '../widgets/publicaciones/publicacion_card.dart';
import '../widgets/publicaciones/crear_publicacion_modal.dart';
import '../widgets/notificaciones/notificaciones_panel.dart';
import '../widgets/app_header.dart';
import '../widgets/app_menu.dart';
import '../screens/login_screen.dart';

class TestArtistaScreen extends StatefulWidget {
  const TestArtistaScreen({super.key});

  @override
  State<TestArtistaScreen> createState() => _TestArtistaScreenState();
}

class _TestArtistaScreenState extends State<TestArtistaScreen> {
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
      debugPrint('Error cargando datos del artista: $e');
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _abrirModalPublicar() async {
    final creoPublicacion = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CrearPublicacionModal(),
    );

    if (creoPublicacion == true) {
      setState(() {});
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
    final nombre = _usuario?['nombre'] ?? 'Artista';
    final idRol = int.tryParse(_usuario?['id_rol']?.toString() ?? '2') ?? 2;
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : 'A';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirModalPublicar,
        elevation: 4,
        highlightElevation: 2,
        backgroundColor: AppTheme.primaryCyan,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
        label: const Text(
          'Nueva Obra',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ),
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
              // Encabezado modular (AppHeader)
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
                child: _HeaderPerfilSection(nombre: nombre),
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
                            'No fue posible cargar las publicaciones.\n${snapshot.error}',
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
                          'No hay obras publicadas aún.',
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
                            child: PublicacionCard(publicacion: publicaciones[index]),
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

class _HeaderPerfilSection extends StatelessWidget {
  final String nombre;

  const _HeaderPerfilSection({required this.nombre});

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
            '¡Hola, $nombre!',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Exhibe tu creatividad y conecta con otros apasionados del arte.',
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