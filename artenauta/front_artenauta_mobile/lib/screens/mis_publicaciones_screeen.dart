import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/publicaciones_service.dart';

class MisPublicacionesScreen extends StatefulWidget {
  final int idUsuario;

  const MisPublicacionesScreen({
    super.key,
    required this.idUsuario,
  });

  @override
  State<MisPublicacionesScreen> createState() => _MisPublicacionesScreenState();
}

class _MisPublicacionesScreenState extends State<MisPublicacionesScreen> {
  bool _cargando = true;
  List<Map<String, dynamic>> _publicaciones = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      setState(() {
        _cargando = true;
      });
      final publicaciones = await PublicacionesService.getPublicacionesPorUsuario(
        widget.idUsuario,
      );
      if (!mounted) return;
      setState(() {
        _publicaciones = publicaciones;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar publicaciones: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // MODAL
  Future<void> _mostrarModalEditar(Map<String, dynamic> pub) async {
    final idPublicacion = int.tryParse(pub['id_publicacion']?.toString() ?? '');
    if (idPublicacion == null) return;

    final tituloController = TextEditingController(text: pub['titulo']?.toString() ?? '');
    final descripcionController = TextEditingController(text: pub['descripcion']?.toString() ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Editar publicación',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descripcionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryCyan,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      await _guardarEdicion(
                        idPublicacion,
                        tituloController.text,
                        descripcionController.text,
                      );
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

Future<void> _guardarEdicion(int idPublicacion, String nuevoTitulo, String nuevaDescripcion) async {
  try {
    await PublicacionesService.editarPublicacion(
      idPublicacion: idPublicacion,
      titulo: nuevoTitulo,
      descripcion: nuevaDescripcion,
    );

    await _cargar();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Publicación actualizada correctamente.'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al actualizar: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  Future<void> _eliminar(int idPublicacion) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar publicación'),
          content: const Text('¿Estás seguro de que deseas eliminar esta publicación?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;
    try {
      await PublicacionesService.eliminarPublicacion(idPublicacion);
      await _cargar();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publicación eliminada.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo eliminar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Publicaciones'),
        backgroundColor: AppTheme.primaryCyan,
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryCyan),
            )
          : _publicaciones.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.collections_outlined,
                        size: 60,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 12),
                      Text('Todavía no tienes publicaciones.'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _publicaciones.length,
                    itemBuilder: (context, index) {
                      final pub = _publicaciones[index];
                      return _buildPublicacion(pub);
                    },
                  ),
                ),
    );
  }

  Widget _buildPublicacion(Map<String, dynamic> pub) {
    final idPublicacion = int.tryParse(pub['id_publicacion']?.toString() ?? '');
    final titulo = pub['titulo']?.toString() ?? 'Sin título';
    final descripcion = pub['descripcion']?.toString() ?? '';
    final contenido = pub['contenido']?.toString();
    final categoria = pub['categorias']?['nombre_categoria']?.toString();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              titulo,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: categoria != null ? Text(categoria) : null,
            trailing: PopupMenuButton<String>(
              onSelected: (opcion) {
                if (opcion == 'editar') {
                  _mostrarModalEditar(pub); // <--- Invoca el modal de edición
                } else if (opcion == 'eliminar' && idPublicacion != null) {
                  _eliminar(idPublicacion);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'editar',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'eliminar',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Eliminar',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (contenido != null && contenido.startsWith('http'))
            ClipRRect(
              child: Image.network(
                contenido,
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          if (descripcion.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Text(descripcion),
            ),
        ],
      ),
    );
  }
}