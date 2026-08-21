import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/mensaje_model.dart';
import '../services/conversaciones_service.dart';
import '../widgets/gradient_header.dart';

class ChatScreen extends StatefulWidget {
  final int idConversacion;
  final String nombreContacto;
  final int miId;

  const ChatScreen({
    super.key,
    required this.idConversacion,
    required this.nombreContacto,
    required this.miId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _mensajeController = TextEditingController();
  final _scrollController = ScrollController();
  List<MensajeModel> _mensajes = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarMensajes();
  }

  Future<void> _cargarMensajes() async {
    final lista = await ConversacionesService.getMensajes(widget.idConversacion);
    setState(() {
      _mensajes = lista;
      _cargando = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _irAlFinal());
  }

  void _irAlFinal() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  Future<void> _enviar() async {
    final texto = _mensajeController.text.trim();
    if (texto.isEmpty) return;
    _mensajeController.clear();
    await ConversacionesService.enviarMensaje(
      idConversacion: widget.idConversacion,
      idUsuario: widget.miId,
      contenido: texto,
    );
    await _cargarMensajes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GradientHeader(
              height: 70,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: AppTheme.primaryCyan),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.nombreContacto,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: _mensajes.length,
                      itemBuilder: (_, i) {
                        final m = _mensajes[i];
                        final esMio = m.idUsuario == widget.miId;
                        return Align(
                          alignment:
                              esMio ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: esMio ? AppTheme.primaryCyan : Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              m.contenido,
                              style: TextStyle(
                                color: esMio ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _mensajeController,
                      decoration: InputDecoration(
                        hintText: 'Envía un mensaje',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (_) => _enviar(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryCyan,
                    child: IconButton(
                      icon: const Icon(Icons.check, color: Colors.white),
                      onPressed: _enviar,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}