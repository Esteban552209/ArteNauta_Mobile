import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/publicaciones_service.dart';
import 'editar_publicacion_dialog.dart';

class MisPublicacionesList extends StatelessWidget {
  final List<Map<String, dynamic>> publicaciones;
  final bool cargando;
  final VoidCallback onRefresh;

  const MisPublicacionesList({
    super.key,
    required this.publicaciones,
    required this.cargando,
    required this.onRefresh,
  });

  void _confirmarEliminacion(BuildContext context, int idPublicacion) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Eliminar publicación?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await PublicacionesService.eliminarPublicacion(idPublicacion);
                onRefresh();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Publicación eliminada'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) return const Center(child: CircularProgressIndicator());

    if (publicaciones.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('Aún no tienes publicaciones.', style: TextStyle(color: AppTheme.textSecondary)),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: publicaciones.length,
      itemBuilder: (context, index) {
        final pub = publicaciones[index];
        final idPub = int.tryParse(pub['id_publicacion'].toString()) ?? 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: pub['imagen_url'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      pub['imagen_url'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image),
                    ),
                  )
                : const Icon(Icons.image, size: 40, color: AppTheme.primaryCyan),
            title: Text(pub['titulo'] ?? 'Sin título', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(pub['descripcion'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => EditarPublicacionDialog(publicacion: pub, onSuccess: onRefresh),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmarEliminacion(context, idPub),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}