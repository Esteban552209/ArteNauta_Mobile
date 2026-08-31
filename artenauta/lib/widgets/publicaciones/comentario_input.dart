import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ComentarioInput extends StatefulWidget {
  final bool cargando;
  final Future<void> Function(String contenido) onEnviar;

  const ComentarioInput({
    super.key,
    required this.cargando,
    required this.onEnviar,
  });

  @override
  State<ComentarioInput> createState() =>
      _ComentarioInputState();
}

class _ComentarioInputState
    extends State<ComentarioInput> {

  final TextEditingController _controller =
      TextEditingController();

  final FocusNode _focusNode =
      FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  Future<void> _enviar() async {
    final contenido =
        _controller.text.trim();

    if (contenido.isEmpty) {
      return;
    }

    await widget.onEnviar(
      contenido,
    );

    if (!mounted) return;

    _controller.clear();

    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        12,
      ),

      decoration:
          BoxDecoration(
        color: Colors.white,

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.08),

            blurRadius: 8,

            offset:
                const Offset(0, -2),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.end,

        children: [
          Expanded(
            child: TextField(
              controller:
                  _controller,

              focusNode:
                  _focusNode,

              minLines: 1,
              maxLines: 4,

              textCapitalization:
                  TextCapitalization.sentences,

              decoration:
                  InputDecoration(
                hintText:
                    'Escribe un comentario...',

                filled: true,

                fillColor:
                    Colors.grey.shade100,

                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    22,
                  ),

                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          Container(
            decoration:
                const BoxDecoration(
              color:
                  AppTheme.primaryCyan,

              shape:
                  BoxShape.circle,
            ),

            child: IconButton(
              onPressed:
                  widget.cargando
                      ? null
                      : _enviar,

              icon: widget.cargando
                  ? const SizedBox(
                      width: 20,
                      height: 20,

                      child:
                          CircularProgressIndicator(
                        color:
                            Colors.white,

                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.send,
                      color:
                          Colors.white,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}