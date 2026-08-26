import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../services/session_service.dart';
import '../services/publicaciones_service.dart';

import '../widgets/app_header.dart';
import '../widgets/app_menu.dart';
import '../widgets/gradient_header.dart';

import '../widgets/publicaciones/publicacion_card.dart';

import 'perfil_screen.dart';
import 'login_screen.dart';

class UsuarioScreen extends StatefulWidget {
  const UsuarioScreen({super.key});

  @override
  State<UsuarioScreen> createState() => _UsuarioScreenState();
}

class _UsuarioScreenState extends State<UsuarioScreen> {
  final PublicacionesService _publicacionesService =
      PublicacionesService();

  Map<String, dynamic>? _usuario;

  List<Map<String, dynamic>> _publicaciones = [];

  bool _cargando = true;

  bool _menuAbierto = false;

  @override
  void initState() {
    super.initState();

    _cargarDatos();
  }

  // ============================================================
  // CARGAR USUARIO Y PUBLICACIONES
  // ============================================================

  Future<void> _cargarDatos() async {
    try {
      final usuario = await SessionService.getUsuario();

      final publicaciones =
          await _publicacionesService.obtenerPublicaciones();

      if (!mounted) return;

      setState(() {
        _usuario = usuario;
        _publicaciones = publicaciones;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al cargar los datos: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // CERRAR SESIÓN
  // ============================================================

  Future<void> _cerrarSesion() async {
    await SessionService.cerrarSesion();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final nombre = _usuario?['nombre'] ?? 'Usuario';

    final idRol =
        int.tryParse(
          _usuario?['id_rol']?.toString() ?? '1',
        ) ??
        1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ======================================================
            // HEADER
            // ======================================================

            AppHeader(
              idRol: idRol,
              nombre: nombre,
              menuAbierto: _menuAbierto,
              onMenuTap: () {
                setState(() {
                  _menuAbierto = !_menuAbierto;
                });
              },
            ),

            // ======================================================
            // CONTENIDO
            // ======================================================

            Expanded(
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // ------------------------------------------------
                      // BIENVENIDA
                      // ------------------------------------------------

                      Padding(
                        padding:
                            const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bienvenido, $nombre',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    AppTheme.primaryCyan,
                              ),
                            ),

                            const SizedBox(height: 4),

                            const Text(
                              'Explora y descubre arte en ArteNauta',
                              style: TextStyle(
                                color:
                                    AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ------------------------------------------------
                      // PUBLICACIONES
                      // ------------------------------------------------

                      Expanded(
                        child: _cargando
                            ? const Center(
                                child:
                                    CircularProgressIndicator(
                                  color:
                                      AppTheme.primaryCyan,
                                ),
                              )
                            : _publicaciones.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No hay publicaciones disponibles.',
                                    ),
                                  )
                                : RefreshIndicator(
                                    color:
                                        AppTheme.primaryCyan,
                                    onRefresh:
                                        _cargarDatos,
                                    child:
                                        ListView.builder(
                                      padding:
                                          const EdgeInsets.all(
                                        12,
                                      ),
                                      itemCount:
                                          _publicaciones.length,
                                      itemBuilder:
                                          (context, index) {
                                        return PublicacionCard(
                                          publicacion:
                                              _publicaciones[
                                                  index],
                                        );
                                      },
                                    ),
                                  ),
                      ),
                    ],
                  ),

                  // ==================================================
                  // MENÚ
                  // ==================================================

                  if (_menuAbierto)
                    Positioned(
                      top: 0,
                      right: 16,
                      child: AppMenu(
                        idRol: idRol,

                        onMiPerfil: () {
                          setState(() {
                            _menuAbierto = false;
                          });

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const PerfilScreen(),
                            ),
                          );
                        },

                        onConversaciones: () {
                          setState(() {
                            _menuAbierto = false;
                          });
                        },

                        onNotificaciones: () {
                          setState(() {
                            _menuAbierto = false;
                          });
                        },

                        onCerrarSesion:
                            _cerrarSesion,
                      ),
                    ),
                ],
              ),
            ),

            // ======================================================
            // FOOTER
            // ======================================================

            const GradientHeader(
              height: 40,
              child: Center(
                child: Text(
                  '©2026 ArteNauta',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
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