import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/session_service.dart';
import '../services/publicaciones_service.dart';
import '../widgets/app_header.dart';
import '../widgets/app_menu.dart';
import '../widgets/gradient_header.dart';
import '../widgets/notificaciones_panel.dart';
import '../screens/perfil_screen.dart';
import '../screens/login_screen.dart';

class TestUsuarioScreen extends StatefulWidget {
  const TestUsuarioScreen({super.key});

  @override
  State<TestUsuarioScreen> createState() => _TestUsuarioScreenState();
}

class _TestUsuarioScreenState extends State<TestUsuarioScreen> {
  final PublicacionesService _publicacionesService = PublicacionesService();
  
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
    final idRol = int.tryParse(_usuario?['id_rol'].toString() ?? '1') ?? 1;

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            if (_menuAbierto) _cerrarMenu();
          },
          child: Column(
            children: [
              AppHeader(
                idRol: idRol,
                nombre: nombre,
                menuAbierto: _menuAbierto,
                onMenuTap: () => setState(() => _menuAbierto = !_menuAbierto),
              ),

              // CONTENIDO PRINCIPAL Y MENÚ
              Expanded(
                child: Stack(
                  children: [
                    // Feed / Muro de publicaciones
                    Column(
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
                            // Llamamos a la API directamente a través del servicio
                            future: _publicacionesService.obtenerPublicaciones(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(color: AppTheme.primaryCyan),
                                );
                              }

                              if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    'Error al cargar publicaciones:\n${snapshot.error}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                );
                              }

                              final publicaciones = snapshot.data ?? [];

                              if (publicaciones.isEmpty) {
                                return const Center(
                                  child: Text('No hay publicaciones disponibles por el momento.'),
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
                                    final pub = publicaciones[index];
                                    return _buildCardPublicacion(pub);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    // MENÚ DESPLEGABLE OVERLAY
                    if (_menuAbierto)
                      Positioned(
                        top: 0,
                        right: 16,
                        child: AppMenu(
                          idRol: idRol,
                          onMiPerfil: () {
                            _cerrarMenu();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const PerfilScreen()),
                            );
                          },
                          onConversaciones: () {
                            _cerrarMenu();
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
        ),
      ),
    );
  }

  Widget _buildCardPublicacion(Map<String, dynamic> pub) {
    final titulo = pub['titulo'] ?? 'Sin título';
    final descripcion = pub['descripcion'] ?? pub['contenido'] ?? '';
    final contenidoUrl = pub['contenido'];

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppTheme.primaryCyan,
              child: Icon(Icons.palette, color: Colors.white),
            ),
            title: Text(
              titulo,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              'Categoría ID: ${pub['id_categoria'] ?? 'General'}',
              style: const TextStyle(fontSize: 12),
            ),
          ),

          if (contenidoUrl != null && contenidoUrl.toString().startsWith('http'))
            Image.network(
              contenidoUrl,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              descripcion,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),

          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Diste like a "$titulo"')),
                    );
                  },
                  icon: const Icon(Icons.favorite_border, color: Colors.redAccent),
                  label: const Text('Me gusta', style: TextStyle(color: Colors.black87)),
                ),
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ver comentarios de "$titulo"')),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline, color: AppTheme.primaryCyan),
                  label: const Text('Comentar', style: TextStyle(color: Colors.black87)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}