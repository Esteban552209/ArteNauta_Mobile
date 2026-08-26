import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/session_service.dart';
import '../../services/comentarios_service.dart';
import 'comentario_item.dart';
import 'comentario_input.dart';

class ComentariosModal extends StatefulWidget {
  final int idPublicacion;
  final String titulo;

  const ComentariosModal({
    super.key,
    required this.idPublicacion,
    required this.titulo,
  });

  @override
  State<ComentariosModal> createState() =>
      _ComentariosModalState();
}

class _ComentariosModalState
    extends State<ComentariosModal> {

  final ComentariosService _comentariosService =
      ComentariosService();

  List<Map<String, dynamic>> _comentarios = [];

  int? _idUsuario;

  bool _cargando = true;

  bool _enviando = false;

  @override
  void initState() {
    super.initState();

    _inicializar();
  }

  Future<void> _inicializar() async {
    final usuario =
        await SessionService.getUsuario();

    final idUsuario =
        int.tryParse(
          usuario?['id_usuario']?.toString() ?? '',
        );

    if (mounted) {
      setState(() {
        _idUsuario = idUsuario;
      });
    }

    await _cargarComentarios();
  }

  Future<void> _cargarComentarios() async {
    try {
      final comentarios =
          await _comentariosService
              .obtenerComentarios(
        widget.idPublicacion,
      );

      if (!mounted) return;

      setState(() {
        _comentarios = comentarios;
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
            'Error al cargar comentarios: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _publicarComentario(
    String contenido,
  ) async {
    if (_idUsuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo identificar al usuario.',
          ),
        ),
      );

      return;
    }

    if (_enviando) {
      return;
    }

    setState(() {
      _enviando = true;
    });

    try {
      await _comentariosService.crearComentario(
        idPublicacion:
            widget.idPublicacion,

        idUsuario:
            _idUsuario!,

        contenido:
            contenido,
      );

      await _cargarComentarios();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo publicar el comentario: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _enviando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboard =
        MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height:
          MediaQuery.of(context).size.height * 0.75,

      padding:
          EdgeInsets.only(
        bottom: keyboard,
      ),

      decoration:
          const BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),

      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              12,
              12,
              8,
            ),

            child: Row(
              children: [
                const Spacer(),

                const Text(
                  'Comentarios',
                  style:
                      TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const Spacer(),

                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  icon:
                      const Icon(Icons.close),
                ),
              ],
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 20,
            ),

            child: Align(
              alignment:
                  Alignment.centerLeft,

              child: Text(
                widget.titulo,

                maxLines: 1,

                overflow:
                    TextOverflow.ellipsis,

                style:
                    const TextStyle(
                  color:
                      AppTheme.primaryCyan,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),

          const Divider(),

          Expanded(
            child: _cargando
                ? const Center(
                    child:
                        CircularProgressIndicator(
                      color:
                          AppTheme.primaryCyan,
                    ),
                  )
                : _comentarios.isEmpty
                    ? const Center(
                        child: Text(
                          'Aún no hay comentarios.',
                          style:
                              TextStyle(
                            color:
                                Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.all(
                          16,
                        ),

                        itemCount:
                            _comentarios.length,

                        itemBuilder:
                            (context, index) {
                          return ComentarioItem(
                            comentario:
                                _comentarios[
                                    index],
                          );
                        },
                      ),
          ),

          ComentarioInput(
            cargando: _enviando,
            onEnviar:
                _publicarComentario,
          ),
        ],
      ),
    );
  }
}