import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/conversacion_model.dart';
import '../services/conversaciones_service.dart';
import '../services/session_service.dart';
import '../widgets/gradient_header.dart';
import 'chat_screen.dart';

class ConversacionesScreen extends StatefulWidget {
  const ConversacionesScreen({super.key});

  @override
  State<ConversacionesScreen> createState() => _ConversacionesScreenState();
}

class _ConversacionesScreenState extends State<ConversacionesScreen> {
  final _buscadorController = TextEditingController();
  List<ConversacionModel> _conversaciones = [];
  List<Map<String, dynamic>> _resultadosBusqueda = [];
  bool _cargando = true;
  bool _buscando = false;
  int? _miId;

  @override
  void initState() {
    super.initState();
    _cargarInicial();
  }

  Future<void> _cargarInicial() async {
    final usuario = await SessionService.getUsuario();
    _miId = int.tryParse(usuario?['id_usuario'].toString() ?? '');
    await _cargarConversaciones();
  }

  Future<void> _cargarConversaciones() async {
    if (_miId == null) return;
    setState(() => _cargando = true);
    final lista = await ConversacionesService.getConversaciones(_miId!);
    setState(() {
      _conversaciones = lista;
      _cargando = false;
    });
  }

  Future<void> _buscar(String query) async {
    if (_miId == null) return;
    if (query.trim().isEmpty) {
      setState(() {
        _buscando = false;
        _resultadosBusqueda = [];
      });
      return;
    }
    final resultados =
        await ConversacionesService.buscarUsuarioPorEmail(query, _miId!);
    setState(() {
      _buscando = true;
      _resultadosBusqueda = resultados;
    });
  }

  Future<void> _abrirOCrearConversacion(int idUsuarioOtro, String nombre) async {
    if (_miId == null) return;
    final idConversacion =
        await ConversacionesService.crearConversacion(_miId!, idUsuarioOtro);
    if (!mounted) return;
    _buscadorController.clear();
    setState(() {
      _buscando = false;
      _resultadosBusqueda = [];
    });
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          idConversacion: idConversacion,
          nombreContacto: nombre,
          miId: _miId!,
        ),
      ),
    );
    _cargarConversaciones();
  }

  Future<void> _confirmarEliminar(ConversacionModel conv) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Deseas eliminar el chat?'),
        content: const Text(
            'Si eliminas la conversación se borrará todo tipo de registro'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryCyan),
            child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await ConversacionesService.eliminarConversacion(conv.idConversacion);
      _cargarConversaciones();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GradientHeader(
              height: 90,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Mis conversaciones',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _buscadorController,
                onChanged: _buscar,
                decoration: InputDecoration(
                  hintText: 'Buscar usuario por correo',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _buscando
                      ? _listaResultados()
                      : _listaConversaciones(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listaResultados() {
    if (_resultadosBusqueda.isEmpty) {
      return const Center(
          child: Text('Sin resultados', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      itemCount: _resultadosBusqueda.length,
      itemBuilder: (_, i) {
        final u = _resultadosBusqueda[i];
        final nombre = '${u['nombre']} ${u['apellido']}';
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(nombre),
          subtitle: Text(u['email'] ?? ''),
          onTap: () => _abrirOCrearConversacion(u['id_usuario'] as int, nombre),
        );
      },
    );
  }

  Widget _listaConversaciones() {
    if (_conversaciones.isEmpty) {
      return const Center(
        child: Text('Aún no tienes conversaciones', style: TextStyle(color: Colors.grey)),
      );
    }
    return RefreshIndicator(
      onRefresh: _cargarConversaciones,
      child: ListView.builder(
        itemCount: _conversaciones.length,
        itemBuilder: (_, i) {
          final c = _conversaciones[i];
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(c.nombreCompleto),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    idConversacion: c.idConversacion,
                    nombreContacto: c.nombreCompleto,
                    miId: _miId!,
                  ),
                ),
              );
              _cargarConversaciones();
            },
            onLongPress: () => _confirmarEliminar(c),
          );
        },
      ),
    );
  }
}