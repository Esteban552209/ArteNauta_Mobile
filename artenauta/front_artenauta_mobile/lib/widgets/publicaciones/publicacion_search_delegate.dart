import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'publicacion_card.dart';

class PublicacionSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> publicaciones;

  PublicacionSearchDelegate({required this.publicaciones});
  @override
  String get searchFieldLabel => 'Buscar por título, artista o categoría...';
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }
  @override
  Widget buildResults(BuildContext context) {
    return _construirListaResultados();
  }
  @override
  Widget buildSuggestions(BuildContext context) {
    return _construirListaResultados();
  }
  Widget _construirListaResultados() {
    if (query.trim().isEmpty) {
      return const Center(
        child: Text(
          'Escribe algo para empezar a buscar obras...',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final queryLower = query.toLowerCase();
    final resultados = publicaciones.where((pub) {

      final titulo = (pub['titulo'] ?? '').toString().toLowerCase();
      final descripcion = (pub['descripcion'] ?? pub['contenido'] ?? '').toString().toLowerCase();

      final usuario = pub['usuarios'] ?? pub['usuario'] ?? {};
      final nombreArtista = '${usuario['nombre'] ?? ''} ${usuario['apellido'] ?? ''}'.toLowerCase();
      
      final categoria = pub['categorias'] ?? pub['categoria'] ?? {};
      final nombreCategoria = (categoria['nombre_categoria'] ?? pub['nombre_categoria'] ?? '').toString().toLowerCase();

      return titulo.contains(queryLower) ||
          descripcion.contains(queryLower) ||
          nombreArtista.contains(queryLower) ||
          nombreCategoria.contains(queryLower);
    }).toList();

    if (resultados.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron publicaciones que coincidan.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: resultados.length,
      itemBuilder: (context, index) {
        return PublicacionCard(publicacion: resultados[index]);
      },
    );
  }
}