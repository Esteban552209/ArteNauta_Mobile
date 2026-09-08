import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme/app_theme.dart';
import '../services/session_service.dart';
import '../widgets/gradient_header.dart';
import '../widgets/perfil/perfil_info_card.dart';
import '../widgets/perfil/perfil_solicitud_card.dart';
import 'perfil_publicaciones_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  Map<String, dynamic>? _usuario;
  bool _cargando = true;

  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final u = await SessionService.getUsuario();
    setState(() {
      _usuario = u;
      _nombreCtrl.text = u?['nombre'] ?? '';
      _apellidoCtrl.text = u?['apellido'] ?? '';
      _telefonoCtrl.text = u?['telefono']?.toString() ?? '';
      _cargando = false;
    });
  }

  Future<void> _guardarPerfil() async {
    final idUsuario = int.tryParse(_usuario?['id_usuario'].toString() ?? '');
    if (idUsuario == null) return;

    try {
      final telefono = int.tryParse(_telefonoCtrl.text.trim());
      await _supabase.from('usuarios').update({
        'nombre': _nombreCtrl.text.trim(),
        'apellido': _apellidoCtrl.text.trim(),
        'telefono': telefono,
      }).eq('id_usuario', idUsuario);

      final token = await SessionService.getToken();
      final usuarioActualizado = {
        ..._usuario!,
        'nombre': _nombreCtrl.text.trim(),
        'apellido': _apellidoCtrl.text.trim(),
        'telefono': telefono,
      };

      await SessionService.guardar(token: token ?? '', usuario: usuarioActualizado);

      setState(() => _usuario = usuarioActualizado);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final idRol = int.tryParse(_usuario?['id_rol'].toString() ?? '1') ?? 1;

    return Scaffold(
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
                        Image.asset('assets/LOGO.png', height: 80, fit: BoxFit.contain),
                        const SizedBox(width: 8),
                        Text(
                          'Panel ${idRol == 3 ? "Admin" : idRol == 2 ? "Artista" : "Usuario"}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),

            // Contenido
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Tarjeta con la información personal y edición de datos
                    PerfilInfoCard(
                      usuario: _usuario,
                      nombreController: _nombreCtrl,
                      apellidoController: _apellidoCtrl,
                      telefonoController: _telefonoCtrl,
                      onGuardar: _guardarPerfil,
                    ),

                    const SizedBox(height: 16),

                    // Tarjeta de navegación a la pantalla de publicaciones
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: const CircleAvatar(
                          backgroundColor: AppTheme.primaryCyan,
                          child: Icon(Icons.collections_outlined, color: Colors.white),
                        ),
                        title: const Text('Mis Publicaciones', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Gestiona y edita tus obras publicadas'),
                        trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.primaryCyan, size: 18),
                        onTap: () {
                          final idUsuario = int.tryParse(_usuario?['id_usuario'].toString() ?? '');
                          if (idUsuario != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PerfilPublicacionesScreen(idUsuario: idUsuario),
                              ),
                            );
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tarjeta de Solicitud para ser Artista (Solo Rol 1)
                    if (idRol == 1)
                      PerfilSolicitudCard(usuario: _usuario),
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