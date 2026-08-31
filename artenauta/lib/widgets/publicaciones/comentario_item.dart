import 'package:flutter/material.dart';

class ComentarioItem extends StatelessWidget {
  final Map<String, dynamic> comentario;

  const ComentarioItem({
    super.key,
    required this.comentario,
  });

  String _formatearFecha(dynamic fecha) {
    if (fecha == null) {
      return '';
    }

    try {
      final date =
          DateTime.parse(
            fecha.toString(),
          ).toLocal();

      final dia =
          date.day.toString().padLeft(2, '0');

      final mes =
          date.month.toString().padLeft(2, '0');

      final hora =
          date.hour.toString().padLeft(2, '0');

      final minuto =
          date.minute.toString().padLeft(2, '0');

      return '$dia/$mes/${date.year} $hora:$minuto';
    } catch (_) {
      return fecha.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final contenido =
        comentario['contenido'] ?? '';

    final idUsuario =
        comentario['id_usuario_final'];

    final fecha =
        comentario['fecha_comentario'];

    return Container(
      margin:
          const EdgeInsets.only(bottom: 12),

      padding:
          const EdgeInsets.all(12),

      decoration:
          BoxDecoration(
        color:
            Colors.grey.shade100,

        borderRadius:
            BorderRadius.circular(14),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          const CircleAvatar(
            radius: 20,

            backgroundColor:
                Colors.cyan,

            child: Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  idUsuario != null
                      ? 'Usuario #$idUsuario'
                      : 'Usuario',

                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  contenido.toString(),
                  style:
                      const TextStyle(
                    fontSize: 14,
                    color:
                        Colors.black87,
                  ),
                ),

                if (fecha != null) ...[
                  const SizedBox(height: 5),

                  Text(
                    _formatearFecha(fecha),

                    style:
                        const TextStyle(
                      fontSize: 11,
                      color:
                          Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}