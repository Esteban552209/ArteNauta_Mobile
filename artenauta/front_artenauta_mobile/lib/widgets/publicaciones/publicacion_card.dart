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

    final titulo = publicacion['titulo'] ?? 'Sin título';
    final descripcion = publicacion['descripcion'] ??publicacion['contenido'] ??'';
    final contenido = publicacion['contenido'];
    final usuario = publicacion['usuarios'] ?? publicacion['usuario'] ?? {};
    final nombreArtista = usuario['nombre'] != null? '${usuario['nombre']} ${usuario['apellido'] ?? ''}'.trim(): 'Artista desconocido';
    final fotoPerfil = usuario['foto_perfil'];
    final categoria = publicacion['categorias'] ?? publicacion['categoria'] ?? {};
    final nombreCategoria = categoria['nombre_categoria'] ??publicacion['nombre_categoria'] ??publicacion['id_categoria']?.toString() ??
        'General';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryCyan,
              backgroundImage: fotoPerfil != null && fotoPerfil.toString().isNotEmpty
                  ? NetworkImage(fotoPerfil.toString())
                  : null,
              child: fotoPerfil == null || fotoPerfil.toString().isEmpty
                  ? const Icon(
                      Icons.palette,
                      color: Colors.white,
                    )
                  : null,
            ),
            title: Text(
              nombreArtista,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              titulo.toString(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),

          if (contenido != null &&
              contenido.toString().startsWith('http'))
            Image.network(
              contenido.toString(),
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return const SizedBox.shrink();
              },
            ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (descripcion.toString().isNotEmpty) ...[
                  Text(
                    descripcion.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryCyan.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                LikeButton(
                  idPublicacion: idPublicacion,
                ),
                TextButton.icon(
                  onPressed: idPublicacion == null
                      ? null
                      : () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) {
                              return ComentariosModal(
                                idPublicacion: idPublicacion,
                                titulo: titulo.toString(),
                              );
                            },
                          );
                        },
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: AppTheme.primaryCyan,
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