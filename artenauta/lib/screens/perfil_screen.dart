import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/session_service.dart';
import '../services/perfil_service.dart';
import '../services/publicaciones_service.dart';
import '../widgets/perfil/perfil_header.dart';
import '../widgets/perfil/perfil_edit_form.dart';
import '../widgets/perfil/publicaciones_propias_card.dart';
import '../widgets/perfil/solicitud_rol_card.dart';
import '../screens/mis_publicaciones_screeen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() =>
      _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final TextEditingController _nombreController =
      TextEditingController();
  final TextEditingController _apellidoController =
      TextEditingController();
  final TextEditingController _telefonoController =
      TextEditingController();

  Map<String, dynamic>? _usuario;

  List<Map<String, dynamic>> _publicaciones = [];

  bool _cargando = true;
  bool _editando = false;
  bool _guardando = false;

  bool _enviandoSolicitud = false;
  bool _solicitudEnviada = false;

  @override
  void initState() {
    super.initState();

    _cargarPerfil();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();

    super.dispose();
  }

  Future<void> _cargarPerfil() async {
    try {
      setState(() {
        _cargando = true;
      });
      final usuarioSesion =
          await SessionService.getUsuario();

      if (usuarioSesion == null) {
        throw Exception(
          'No se encontró una sesión activa.',
        );
      }
      final idUsuario = int.tryParse(
        usuarioSesion['id_usuario']
            ?.toString() ??
            '',
      );
      if (idUsuario == null) {
        throw Exception(
          'No se pudo obtener el ID del usuario.',
        );
      }
      final perfil =
          await PerfilService.obtenerPerfil(
        idUsuario,
      );

      final publicaciones =
          await PublicacionesService
              .getPublicacionesPorUsuario(
        idUsuario,
      );
      final solicitudPendiente =
          await PerfilService
              .tieneSolicitudPendiente(
        idUsuario,
      );

      if (!mounted) return;
      _llenarControllers(perfil);
      setState(() {
        _usuario = perfil;
        _publicaciones = publicaciones;
        _solicitudEnviada =
            solicitudPendiente;
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
            e.toString()
                .replaceAll('Exception: ', ''),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  void _llenarControllers(
    Map<String, dynamic> usuario,
  ) {
    _nombreController.text =
        usuario['nombre']?.toString() ?? '';

    _apellidoController.text =
        usuario['apellido']?.toString() ?? '';

    _telefonoController.text =
        usuario['telefono']?.toString() ?? '';
  }

  void _toggleEditar() {
    if (_editando && _usuario != null) {
      _llenarControllers(_usuario!);
    }

    setState(() {
      _editando = !_editando;
    });
  }
  Future<void> _guardarCambios() async {
    if (_usuario == null || _guardando) {
      return;
    }

    final nombre =
        _nombreController.text.trim();

    final apellido =
        _apellidoController.text.trim();

    final telefonoTexto =
        _telefonoController.text.trim();

    if (nombre.isEmpty || apellido.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El nombre y el apellido son obligatorios.',
          ),
        ),
      );

      return;
    }

    int? telefono;

    if (telefonoTexto.isNotEmpty) {
      telefono =
          int.tryParse(telefonoTexto);

      if (telefono == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'El teléfono debe contener solamente números.',
            ),
          ),
        );

        return;
      }
    }

    final idUsuario = int.tryParse(
      _usuario!['id_usuario']
          ?.toString() ??
          '',
    );

    if (idUsuario == null) return;

    try {
      setState(() {
        _guardando = true;
      });

      await PerfilService.actualizarPerfil(
        idUsuario: idUsuario,
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,
      );

      final perfilActualizado =
          await PerfilService.obtenerPerfil(
        idUsuario,
      );

      final token =
          await SessionService.getToken();

      if (token != null) {
        await SessionService.guardar(
          token: token,
          usuario: perfilActualizado,
        );
      }

      if (!mounted) return;

      _llenarControllers(
        perfilActualizado,
      );

      setState(() {
        _usuario =
            perfilActualizado;

        _editando = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Perfil actualizado correctamente.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString()
                .replaceAll(
                  'Exception: ',
                  '',
                ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  Future<void> _solicitarArtista() async {
    if (_usuario == null ||
        _enviandoSolicitud ||
        _solicitudEnviada) {
      return;
    }
    final idUsuario = int.tryParse(
      _usuario!['id_usuario']
              ?.toString() ??
          '',
    );
    if (idUsuario == null) return;
    final nombre =
        _usuario!['nombre']
                ?.toString() ??
            'Usuario';
    final apellido =
        _usuario!['apellido']
                ?.toString() ??
            '';
    try {
      setState(() {
        _enviandoSolicitud = true;
      });
      await PerfilService
          .enviarSolicitudArtista(
        idUsuario: idUsuario,
        nombreUsuario:
            '$nombre $apellido'.trim(),
      );
      if (!mounted) return;
      setState(() {
        _solicitudEnviada = true;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Solicitud enviada correctamente.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString()
                .replaceAll(
                  'Exception: ',
                  '',
                ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _enviandoSolicitud = false;
        });
      }
    }
  }

  Future<void> _abrirMisPublicaciones() async {
    if (_usuario == null) return;

    final idUsuario = int.tryParse(
      _usuario!['id_usuario']
              ?.toString() ??
          '',
    );
    if (idUsuario == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MisPublicacionesScreen(
          idUsuario: idUsuario,
        ),
      ),
    );

    await _recargarPublicaciones();
  }
  Future<void> _recargarPublicaciones() async {
    if (_usuario == null) return;

    final idUsuario = int.tryParse(
      _usuario!['id_usuario']
              ?.toString() ??
          '',
    );

    if (idUsuario == null) return;

    final publicaciones =
        await PublicacionesService
            .getPublicacionesPorUsuario(
      idUsuario,
    );

    if (!mounted) return;

    setState(() {
      _publicaciones = publicaciones;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryCyan,
          ),
        ),
      );
    }

    if (_usuario == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No se pudo cargar el perfil.',
          ),
        ),
      );
    }

    final nombre =
        _usuario!['nombre']?.toString() ??
            '';
    final apellido =
        _usuario!['apellido']?.toString() ??
            '';
    final email =
        _usuario!['email']?.toString() ??
            '';
    final idRol = int.tryParse(
          _usuario!['id_rol']
                  ?.toString() ??
              '1',
        ) ??
        1;
    final inicial = nombre.isNotEmpty
        ? nombre[0].toUpperCase()
        : '?';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor:
            AppTheme.primaryCyan,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryCyan,
        onRefresh: _cargarPerfil,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.all(16),

          child: Column(
            children: [

              PerfilHeader(
                nombre: nombre,
                apellido: apellido,
                email: email,
                inicial: inicial,
                cantidadObras:
                    _publicaciones.length,
                cantidadSeguidores: 0,
                editando: _editando,
                onToggleEditar:
                    _toggleEditar,
              ),

              if (_editando) ...[
                const SizedBox(height: 16),
                PerfilEditForm(
                  nombreController:
                      _nombreController,
                  apellidoController:
                      _apellidoController,
                  telefonoController:
                      _telefonoController,

                  onGuardar:
                      _guardando
                          ? () {}
                          : _guardarCambios,
                ),
              ],
              if (idRol == 2) ...[
              const SizedBox(height: 16),

              PublicacionesPropiasCard(
                onTapVerPublicaciones:
                    _abrirMisPublicaciones,
              ),],

              if (idRol == 1) ...[
                const SizedBox(height: 16),
                SolicitudRolCard(
                  enviandoSolicitud:
                      _enviandoSolicitud,
                  solicitudEnviada:
                      _solicitudEnviada,

                  onSolicitar:
                      _solicitarArtista,
                ),
              ],

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}