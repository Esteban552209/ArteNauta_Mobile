import 'package:flutter/material.dart';
import '../../services/session_service.dart';
import '../../services/admin/comentarios_service.dart'; 
import '../../core/theme/app_theme.dart';
import '../../widgets/gradient_header.dart';

class GestionComentariosScreen extends StatefulWidget {
  const GestionComentariosScreen({super.key});

  @override
  State<GestionComentariosScreen> createState() => _GestionComentariosScreenState();
}

class _GestionComentariosScreenState extends State<GestionComentariosScreen> {
  List<dynamic> _comentarios = [];
  bool _isLoading = true;

  final ComentariosService _comentariosService = ComentariosService();

  @override
  void initState() {
    super.initState();
    _cargarComentarios();
  }

  Future<void> _cargarComentarios() async {
    setState(() => _isLoading = true);
    try {
      final String? token = await SessionService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final data = await _comentariosService.getComentariosAdmin(token);

      setState(() => _comentarios = data);
    } catch (e) {
      debugPrint("Error GET Comentarios: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar comentarios: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _eliminarComentario(int idComentario) async {
    bool confirmar = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Comentario'),
        content: const Text('¿Estás seguro de que deseas eliminar este comentario?'),
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

      await _comentariosService.eliminarComentario(
        token: token,
        idComentario: idComentario,
      );

      _cargarComentarios();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comentario eliminado correctamente'), backgroundColor: Colors.green),
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
                      'Gestión de Comentarios',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _cargarComentarios,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: _comentarios.length,
                    itemBuilder: (context, index) {
                      final c = _comentarios[index];
                      final usuario = c['usuarios'] ?? {};
                      final publicacion = c['publicaciones'] ?? {};

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppTheme.primaryCyan.withOpacity(0.2),
                                    child: const Icon(Icons.person, color: AppTheme.primaryCyan, size: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      usuario['nombre'] ?? 'Usuario Desconocido',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _eliminarComentario(c['id_comentario']),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                c['contenido'] ?? '',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8)
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.article_outlined, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'En: ${publicacion['titulo'] ?? 'Publicación'}',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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