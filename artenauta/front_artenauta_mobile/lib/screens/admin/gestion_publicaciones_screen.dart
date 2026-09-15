import 'package:flutter/material.dart';
import '../../services/session_service.dart';
import '../../services/admin/publicaciones_service.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/gradient_header.dart';

class GestionPublicacionesScreen extends StatefulWidget {
  const GestionPublicacionesScreen({super.key});

  @override
  State<GestionPublicacionesScreen> createState() => _GestionPublicacionesScreenState();
}

class _GestionPublicacionesScreenState extends State<GestionPublicacionesScreen> {
  List<dynamic> _publicaciones = [];
  bool _isLoading = true;

  final _buscarController = TextEditingController();
  final PublicacionesService _publicacionesService = PublicacionesService();

  @override
  void initState() {
    super.initState();
    _cargarPublicaciones();
  }

  Future<void> _cargarPublicaciones() async {
    setState(() => _isLoading = true);
    try {
      final String? token = await SessionService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final data = await _publicacionesService.getPublicaciones(
        token,
        buscar: _buscarController.text,
      );

      setState(() => _publicaciones = data);
    } catch (e) {
      debugPrint("Error GET Publicaciones: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _eliminarPublicacion(int idPublicacion) async {
    bool confirmar = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Publicación'),
        content: const Text('¿Estás seguro de que deseas eliminar esta publicación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmar) return;

    try {
      final String? token = await SessionService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      await _publicacionesService.eliminarPublicacion(
        token: token,
        idPublicacion: idPublicacion,
      );

      _cargarPublicaciones();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publicación eliminada correctamente'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint("Error DELETE: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          GradientHeader(
            height: 110,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Gestión de Publicaciones',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _buscarController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por título o descripción...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onSubmitted: (_) => _cargarPublicaciones(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: AppTheme.primaryCyan),
                  onPressed: _cargarPublicaciones,
                )
              ],
            ),
          ),

          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _cargarPublicaciones,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _publicaciones.length,
                    itemBuilder: (context, index) {
                      final p = _publicaciones[index];
                      final usuario = p['usuarios'] ?? {};
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primaryCyan.withOpacity(0.2),
                                child: const Icon(Icons.person, color: AppTheme.primaryCyan),
                              ),
                              title: Text(usuario['nombre'] ?? 'Desconocido', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(usuario['email'] ?? '', style: const TextStyle(fontSize: 12)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _eliminarPublicacion(p['id_publicacion']),
                                  ),
                                ],
                              ),
                            ),
                            if (p['contenido'] != null && p['contenido'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    p['contenido'],
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      height: 150,
                                      color: Colors.grey[200],
                                      child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                                    ),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p['titulo'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(
                                    p['descripcion'] ?? '',
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  if (p['categorias'] != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryCyan.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        p['categorias']['nombre_categoria'] ?? '',
                                        style: const TextStyle(fontSize: 12, color: AppTheme.primaryCyan, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
          ),
        ],
      ),
    );
  }
}