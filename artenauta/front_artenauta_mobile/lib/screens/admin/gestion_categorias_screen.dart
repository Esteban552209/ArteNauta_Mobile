import 'package:flutter/material.dart';
import '../../services/session_service.dart';
import '../../services/admin/categorias_service.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/gradient_header.dart';

class GestionCategoriasScreen extends StatefulWidget {
  const GestionCategoriasScreen({super.key});

  @override
  State<GestionCategoriasScreen> createState() => _GestionCategoriasScreenState();
}

class _GestionCategoriasScreenState extends State<GestionCategoriasScreen> {
  List<dynamic> _categorias = [];
  bool _isLoading = true;

  final _buscarController = TextEditingController();
  final CategoriasService _categoriasService = CategoriasService();

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    setState(() => _isLoading = true);
    try {
      final String? token = await SessionService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final data = await _categoriasService.getCategorias(
        token,
        buscar: _buscarController.text,
      );

      setState(() => _categorias = data);
    } catch (e) {
      debugPrint("Error GET Categorías: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _mostrarModalFormulario({Map<String, dynamic>? categoria}) {
    final isEditing = categoria != null;
    final nombreCtrl = TextEditingController(text: isEditing ? categoria['nombre_categoria'] : '');
    final descripcionCtrl = TextEditingController(text: isEditing ? categoria['descripcion'] : '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isEditing ? 'Editar Categoría' : 'Nueva Categoría', style: const TextStyle(color: AppTheme.primaryCyan)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre Categoría'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descripcionCtrl,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryCyan),
              onPressed: () async {
                Navigator.pop(ctx);

                if (isEditing) {
                  await _actualizarCategoria(
                    idCategoria: categoria['id_categoria'],
                    nombre: nombreCtrl.text,
                    descripcion: descripcionCtrl.text,
                  );
                } else {
                  await _crearCategoria(
                    nombre: nombreCtrl.text,
                    descripcion: descripcionCtrl.text,
                  );
                }
              },
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _crearCategoria({
    required String nombre,
    required String descripcion,
  }) async {
    try {
      final String? token = await SessionService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      await _categoriasService.crearCategoria(
        token: token,
        nombre: nombre,
        descripcion: descripcion,
      );

      _cargarCategorias();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Categoría creada correctamente'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint("Error POST: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _actualizarCategoria({
    required int idCategoria,
    required String nombre,
    required String descripcion,
  }) async {
    try {
      final String? token = await SessionService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      await _categoriasService.actualizarCategoria(
        token: token,
        idCategoria: idCategoria,
        nombre: nombre,
        descripcion: descripcion,
      );

      _cargarCategorias();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Categoría actualizada correctamente'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint("Error PATCH: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryCyan,
        onPressed: () => _mostrarModalFormulario(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
                      'Gestión de Categorías',
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
                      hintText: 'Buscar categoría...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onSubmitted: (_) => _cargarCategorias(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: AppTheme.primaryCyan),
                  onPressed: _cargarCategorias,
                )
              ],
            ),
          ),

          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _cargarCategorias,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categorias.length,
                    itemBuilder: (context, index) {
                      final c = _categorias[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryCyan.withOpacity(0.2),
                            child: const Icon(Icons.category, color: AppTheme.primaryCyan),
                          ),
                          title: Text(c['nombre_categoria'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            c['descripcion'] ?? '', 
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12)
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.grey),
                            onPressed: () => _mostrarModalFormulario(categoria: c),
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