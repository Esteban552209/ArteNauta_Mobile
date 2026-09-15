import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/publicaciones_service.dart';

class MisPublicacionesScreen
    extends StatefulWidget {

  final int idUsuario;

  const MisPublicacionesScreen({
    super.key,
    required this.idUsuario,
  });
  @override
  State<MisPublicacionesScreen>
      createState() =>
          _MisPublicacionesScreenState();
}

class _MisPublicacionesScreenState
    extends State<MisPublicacionesScreen> {
  bool _cargando = true;
  List<Map<String, dynamic>>
      _publicaciones = [];
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
      final publicaciones =
          await PublicacionesService
              .getPublicacionesPorUsuario(
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

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Error al cargar publicaciones: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _eliminar(
    int idPublicacion,
  ) async {
    final confirmar =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text(
            'Eliminar publicación',
          ),
          content:
              const Text(
            '¿Estás seguro de que deseas eliminar esta publicación?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                false,
              ),
              child:
                  const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                true,
              ),
              child:
                  const Text(
                'Eliminar',
                style:
                    TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;
    try {
      await PublicacionesService
          .eliminarPublicacion(
        idPublicacion,
      );

      await _cargar();
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Publicación eliminada.',
          ),
        ),
      );
    } 
    catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo eliminar: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Mis Publicaciones',
        ),
        backgroundColor:
            AppTheme.primaryCyan,
        foregroundColor:
            Colors.white,
      ),

      body: _cargando
          ? const Center(
              child:
                  CircularProgressIndicator(
                color:
                    AppTheme.primaryCyan,
              ),
            )
          : _publicaciones.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Icon(
                        Icons
                            .collections_outlined,
                        size: 60,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Todavía no tienes publicaciones.',
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child:
                      ListView.builder(
                    padding:
                        const EdgeInsets.all(
                      12,
                    ),
                    itemCount:
                        _publicaciones.length,
                    itemBuilder:
                        (context, index) {
                      final pub =
                          _publicaciones[
                              index];
                      return _buildPublicacion(
                        pub,
                      );
                    },
                  ),
                ),
    );
  }
  Widget _buildPublicacion(
    Map<String, dynamic> pub,
  ) {
    final idPublicacion =
        int.tryParse(
          pub['id_publicacion']
                  ?.toString() ??
              '',
        );
    final titulo =
        pub['titulo']?.toString() ??
            'Sin título';
    final descripcion =
        pub['descripcion']?.toString() ??
            '';
    final contenido =
        pub['contenido']?.toString();

    final categoria =
        pub['categorias']
            ?['nombre_categoria']
            ?.toString();
    return Card(
      elevation: 2,
      margin:
          const EdgeInsets.only(
        bottom: 16,
      ),
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              titulo,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            subtitle: categoria != null
                ? Text(categoria)
                : null,
            trailing:
                PopupMenuButton<String>(
              onSelected: (opcion) {
                if (opcion == 'eliminar' &&
                    idPublicacion != null) {
                  _eliminar(
                    idPublicacion,
                  );
                }

              },

              itemBuilder:
                  (context) => [
                const PopupMenuItem(
                  value: 'editar',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                      ),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),

                const PopupMenuItem(
                  value: 'eliminar',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Eliminar',
                        style:
                            TextStyle(
                          color:
                              Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (contenido != null &&
              contenido.startsWith('http'))
            ClipRRect(
              child: Image.network(
                contenido,
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) =>
                        const SizedBox
                            .shrink(),
              ),
            ),

          if (descripcion.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.all(
                14,
              ),
              child:
                  Text(descripcion),
            ),
        ],
      ),
    );
  }
}