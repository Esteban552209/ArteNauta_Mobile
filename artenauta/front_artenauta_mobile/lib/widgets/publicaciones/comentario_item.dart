import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:art_sweetalert_new/art_sweetalert_new.dart';

class ComentarioItem extends StatelessWidget {
  final Map<String, dynamic> comentario;
  final bool esPropietario;
  final VoidCallback? onEliminar;

  const ComentarioItem({
    super.key,
    required this.comentario,
    this.esPropietario = false,
    this.onEliminar,
  });

  String _formatearFecha(dynamic fecha) {
    if (fecha == null) return '';
    try {
      final date = DateTime.parse(fecha.toString()).toLocal();
      final dia = date.day.toString().padLeft(2, '0');
      final mes = date.month.toString().padLeft(2, '0');
      final hora = date.hour.toString().padLeft(2, '0');
      final minuto = date.minute.toString().padLeft(2, '0');
      return '$dia/$mes/${date.year} $hora:$minuto';
    } catch (_) {
      return fecha.toString();
    }
  }

  void _confirmarEliminacion(BuildContext context) {
    ArtSweetAlert.show(
      context: context,
        type: ArtAlertType.warning,
        title: const Text('¿Desea eliminar el comentario?'),
        actions: [
          ArtAlertButton(
            onPressed: () => Navigator.pop(context,true,),
            backgroundColor: AppTheme.primaryCyan,
            textColor: Colors.white,
            child: const Text('Eliminar'),
          ),
        ],
    ).then((result) {
      if (result == true) {
        if (onEliminar != null) {
          onEliminar!();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final contenido = comentario['contenido'] ?? '';
    final fecha = comentario['fecha_comentario'];
    final usuario = comentario['usuarios'] ?? comentario;
    final nombreAutor = usuario['nombre'] != null 
        ? '${usuario['nombre']} ${usuario['apellido'] ?? ''}'.trim()
        : 'Usuario #${comentario['id_usuario_final'] ?? comentario['id_usuario'] ?? ''}';
    final fotoPerfil = usuario['foto_perfil'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.cyan,
            backgroundImage: fotoPerfil != null && fotoPerfil.isNotEmpty
                ? NetworkImage(fotoPerfil)
                : null,
            child: fotoPerfil == null || fotoPerfil.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        nombreAutor,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (esPropietario && onEliminar != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        onPressed: () => _confirmarEliminacion(context),
                        tooltip: 'Eliminar comentario',
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  contenido.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                if (fecha != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    _formatearFecha(fecha),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
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