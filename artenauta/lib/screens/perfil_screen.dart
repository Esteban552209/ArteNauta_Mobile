import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme/app_theme.dart';
import '../widgets/gradient_header.dart';
import '../services/session_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  Map<String, dynamic>? _usuario;
  bool _cargando = true;
  bool _editando = false;
  bool _enviandoSolicitud = false;
  bool _solicitudEnviada = false;

  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _telefonoController = TextEditingController();

  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final u = await SessionService.getUsuario();
    setState(() {
      _usuario = u;
      _nombreController.text = u?['nombre'] ?? '';
      _apellidoController.text = u?['apellido'] ?? '';
      _telefonoController.text = u?['telefono']?.toString() ?? '';
      _cargando = false;
    });
  }

  Future<void> _guardarCambios() async {
  final idUsuarioRaw = _usuario?['id_usuario'];
  final idUsuario = int.tryParse(idUsuarioRaw.toString());

  if (idUsuario == null) return;

  // Teléfono puede ser null si está vacío — Supabase lo acepta
  final telefonoRaw = _telefonoController.text.trim();
  final telefono = telefonoRaw.isEmpty ? null : int.tryParse(telefonoRaw);

  try {
    await _supabase
        .from('usuarios')
        .update({
          'nombre': _nombreController.text.trim(),
          'apellido': _apellidoController.text.trim(),
          'telefono': telefono, // null si está vacío, número si tiene valor
        })
        .eq('id_usuario', idUsuario);

    final token = await SessionService.getToken();
    final usuarioActualizado = {
      ..._usuario!,
      'nombre': _nombreController.text.trim(),
      'apellido': _apellidoController.text.trim(),
      'telefono': telefono,
    };
    await SessionService.guardar(
      token: token ?? '',
      usuario: usuarioActualizado,
    );

    setState(() {
      _usuario = usuarioActualizado;
      _editando = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil actualizado correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  Future<void> _enviarSolicitud() async {
    setState(() => _enviandoSolicitud = true);
    final idUsuarioRaw = _usuario?['id_usuario'];
    final idUsuario = int.tryParse(idUsuarioRaw.toString());

    if (idUsuario == null) {
      setState(() => _enviandoSolicitud = false);
      return;
    }

    try {
      // 1. Verificar si ya tiene solicitud pendiente
      final existente = await _supabase
          .from('solicitudes')
          .select('id_solicitud')
          .eq('id_usuario', idUsuario)
          .eq('tipo_solicitud', 'artista')
          .eq('estado_solicitud', 'Pendiente')
          .maybeSingle();

      if (existente != null) {
        setState(() => _enviandoSolicitud = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ya tienes una solicitud pendiente'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // 2. Crear la solicitud
      await _supabase.from('solicitudes').insert({
        'id_usuario': idUsuario,
        'tipo_solicitud': 'artista',
        'estado_solicitud': 'Pendiente',
        'fecha_solicitud': DateTime.now().toIso8601String(),
      });

      // 3. Notificar a todos los admins
      final admins = await _supabase
          .from('usuarios')
          .select('id_usuario')
          .eq('id_rol', 3);

      if ((admins as List).isNotEmpty) {
        final notifs = admins.map((a) => {
          'id_usuario': a['id_usuario'],
          'asunto': '${_usuario?['nombre']} quiere ser artista',
          'tipo_notificacion': 'nueva_solicitud_artista',
          'fecha_notificacion': DateTime.now().toIso8601String(),
        }).toList();
        await _supabase.from('notificaciones').insert(notifs);
      }

      setState(() {
        _enviandoSolicitud = false;
        _solicitudEnviada = true;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Solicitud enviada! El administrador la revisará.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _enviandoSolicitud = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mostrarDialogoSolicitud() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '¿Solicitar ser artista?',
          style: TextStyle(
              color: AppTheme.primaryCyan,
              fontWeight: FontWeight.bold,
              fontSize: 16),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Se enviará una solicitud al administrador para cambiar tu rol.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _enviarSolicitud();
            },
            child: const Text('Sí, solicitar',
                style: TextStyle(
                    color: AppTheme.primaryCyan,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  // Título dinámico según rol
  String _tituloPanel(int rol) {
    switch (rol) {
      case 3: return 'Panel Admin';
      case 2: return 'Panel Artista';
      default: return 'Panel Usuario';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final nombre = _usuario?['nombre'] ?? 'Usuario';
    final apellido = _usuario?['apellido'] ?? '';
    final email = _usuario?['email'] ?? '';
    final idRol =
        int.tryParse(_usuario?['id_rol'].toString() ?? '1') ?? 1;
    final inicial =
        nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // HEADER — dinámico según rol
            GradientHeader(
              height: 100,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/LOGO.png',
                            height: 80, fit: BoxFit.contain),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _tituloPanel(idRol),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                            Text(
                              'Bienvenido, $nombre',
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),

            // CONTENIDO
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // TARJETA PERFIL
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: AppTheme.primaryCyan
                                  .withValues(alpha: 0.15),
                              child: Text(
                                inicial,
                                style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryCyan),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: const [
                                _Stat(valor: '0', label: 'Obras'),
                                SizedBox(width: 32),
                                _Stat(
                                    valor: '0',
                                    label: 'Seguidores'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '$nombre $apellido',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(email,
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13)),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => setState(
                                    () => _editando = !_editando),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AppTheme.primaryCyan,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20)),
                                ),
                                child: Text(_editando
                                    ? 'Cancelar'
                                    : 'Editar Perfil'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // FORMULARIO EDICIÓN
                    if (_editando)
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text('Editar información',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: AppTheme.primaryCyan)),
                              const SizedBox(height: 16),
                              _Campo(
                                label: 'Nombre',
                                controller: _nombreController,
                                icono: Icons.person_outline,
                              ),
                              const SizedBox(height: 12),
                              _Campo(
                                label: 'Apellido',
                                controller: _apellidoController,
                                icono: Icons.person_outline,
                              ),
                              const SizedBox(height: 12),
                              _Campo(
                                label: 'Teléfono',
                                controller: _telefonoController,
                                icono: Icons.phone_outlined,
                                tipo: TextInputType.phone,
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _guardarCambios,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppTheme.primaryCyan,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                                10)),
                                  ),
                                  child: const Text(
                                      'Guardar cambios'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // SOLICITAR SER ARTISTA — solo rol 1
                    if (idRol == 1)
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                              color: AppTheme.primaryCyan
                                  .withValues(alpha: 0.3)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.brush_outlined,
                                      color: AppTheme.primaryCyan,
                                      size: 20),
                                  SizedBox(width: 8),
                                  Text('¿Quieres ser Artista?',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              AppTheme.primaryCyan)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Solicita el cambio de rol al administrador.',
                                style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13),
                              ),
                              const SizedBox(height: 12),
                              if (_solicitudEnviada)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius:
                                        BorderRadius.circular(10),
                                    border: Border.all(
                                        color:
                                            Colors.green.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                          Icons
                                              .check_circle_outline,
                                          color:
                                              Colors.green.shade600,
                                          size: 18),
                                      const SizedBox(width: 8),
                                      const Expanded(
                                        child: Text(
                                          '¡Solicitud enviada! El administrador revisará tu solicitud.',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.green),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                GestureDetector(
                                  onTap: _enviandoSolicitud
                                      ? null
                                      : _mostrarDialogoSolicitud,
                                  child: Text(
                                    _enviandoSolicitud
                                        ? 'Enviando...'
                                        : 'Solicitar ser Artista',
                                    style: TextStyle(
                                      color: _enviandoSolicitud
                                          ? Colors.grey
                                          : AppTheme.primaryCyan,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
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
                      fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String valor;
  final String label;
  const _Stat({required this.valor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(valor,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 12)),
      ],
    );
  }
}

class _Campo extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icono;
  final TextInputType tipo;

  const _Campo({
    required this.label,
    required this.controller,
    required this.icono,
    this.tipo = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: tipo,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icono, color: AppTheme.primaryCyan),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              color: AppTheme.primaryCyan, width: 2),
        ),
      ),
    );
  }
}