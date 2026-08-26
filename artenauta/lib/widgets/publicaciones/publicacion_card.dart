import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'like_button.dart';
import 'comentario_modal.dart';

class PublicacionCard extends StatelessWidget {
  final Map<String, dynamic> publicacion;

  const PublicacionCard({
    super.key,
    required this.publicacion,
  });

  @override
  Widget build(BuildContext context) {
    final idPublicacion = int.tryParse(
      publicacion['id_publicacion']?.toString() ?? '',
    );

    final titulo =
        publicacion['titulo'] ?? 'Sin título';

    final descripcion =
        publicacion['descripcion'] ??
        publicacion['contenido'] ??
        '';

    final contenido =
        publicacion['contenido'];

    final idCategoria =
        publicacion['id_categoria'] ?? 'General';

    return Card(
      elevation: 3,

      margin:
          const EdgeInsets.only(bottom: 16),

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ======================================================
          // CABECERA
          // ======================================================

          ListTile(
            leading:
                const CircleAvatar(
              backgroundColor:
                  AppTheme.primaryCyan,

              child: Icon(
                Icons.palette,
                color: Colors.white,
              ),
            ),

            title: Text(
              titulo.toString(),
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 16,
              ),
            ),

            subtitle: Text(
              'Categoría ID: $idCategoria',
              style:
                  const TextStyle(
                fontSize: 12,
              ),
            ),
          ),

          // ======================================================
          // IMAGEN
          // ======================================================

          if (contenido != null &&
              contenido
                  .toString()
                  .startsWith('http'))
            Image.network(
              contenido.toString(),
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,

              errorBuilder:
                  (_, __, ___) {
                return const SizedBox.shrink();
              },
            ),

          // ======================================================
          // DESCRIPCIÓN
          // ======================================================

          Padding(
            padding:
                const EdgeInsets.all(12),
            child: Text(
              descripcion.toString(),
              style:
                  const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),

          const Divider(height: 1),

          // ======================================================
          // BOTONES
          // ======================================================

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),

            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
              children: [
                // ------------------------------------------------
                // LIKE
                // ------------------------------------------------

                LikeButton(
                  idPublicacion:
                      idPublicacion,
                ),

                // ------------------------------------------------
                // COMENTARIOS
                // ------------------------------------------------

                TextButton.icon(
                  onPressed:
                      idPublicacion == null
                          ? null
                          : () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled:
                                    true,
                                useSafeArea: true,
                                backgroundColor:
                                    Colors.transparent,
                                builder: (_) {
                                  return ComentariosModal(
                                    idPublicacion:
                                        idPublicacion,
                                    titulo:
                                        titulo.toString(),
                                  );
                                },
                              );
                            },

                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color:
                        AppTheme.primaryCyan,
                  ),

                  label: const Text(
                    'Comentar',
                    style: TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}