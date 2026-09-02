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

    String _formatoFecha(DateTime? fecha) {
    if (fecha == null) return '';
    final ahora = DateTime.now();
    final esHoy = fecha.year == ahora.year &&
        fecha.month == ahora.month &&
        fecha.day == ahora.day;
    if (esHoy) {
      final hora = fecha.hour.toString().padLeft(2, '0');
      final min = fecha.minute.toString().padLeft(2, '0');
      return '$hora:$min';
    }
    final ayer = ahora.subtract(const Duration(days: 1));
    final esAyer = fecha.year == ayer.year &&
        fecha.month == ayer.month &&
        fecha.day == ayer.day;
    if (esAyer) return 'Ayer';
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}';
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
          final tieneNoLeidos = c.noLeidos > 0;
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(
              c.nombreCompleto,
              style: TextStyle(
                fontWeight: tieneNoLeidos ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: c.ultimoMensaje == null
                ? null
                : Text(
                    c.ultimoMensaje!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: tieneNoLeidos ? Colors.black87 : Colors.grey,
                      fontWeight: tieneNoLeidos ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatoFecha(c.fechaUltimoMensaje),
                  style: TextStyle(
                    fontSize: 12,
                    color: tieneNoLeidos ? AppTheme.primaryCyan : Colors.grey,
                    fontWeight: tieneNoLeidos ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                if (tieneNoLeidos)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryCyan,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: const BoxConstraints(minWidth: 20),
                    child: Text(
                      c.noLeidos > 99 ? '99+' : '${c.noLeidos}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
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