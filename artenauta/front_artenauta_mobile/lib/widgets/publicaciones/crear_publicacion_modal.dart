import 'package:flutter/material.dart';
import 'package:art_sweetalert_new/art_sweetalert_new.dart';
import 'package:artenauta/services/publicaciones_service.dart';
import 'package:artenauta/core/theme/app_theme.dart';


class CrearPublicacionModal extends StatefulWidget {
  const CrearPublicacionModal({super.key});

  @override
  State<CrearPublicacionModal> createState() => _CrearPublicacionModalState();
}

class _CrearPublicacionModalState extends State<CrearPublicacionModal> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _urlImagenController = TextEditingController();

  List<Map<String, dynamic>> _categorias = [];
  int? _categoriaSeleccionadaId;
  bool _cargandoCategorias = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _urlImagenController.dispose();
    super.dispose();
  }

  Future<void> _cargarCategorias() async {
    try {
      final categorias = await PublicacionesService.obtenerCategorias();
      setState(() {
        _categorias = categorias;
        _cargandoCategorias = false;
      });
    } catch (e) {
      setState(() => _cargandoCategorias = false);
      if (!mounted) return;
      ArtSweetAlert.show(
        context: context,
        type: ArtAlertType.error,
        title: const Text('Error'),
        content: const Text(
                'No se pudieron cargar las categorias',
              ),
      );
    }
  }

  Future<void> _publicar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_categoriaSeleccionadaId == null) {
      ArtSweetAlert.show(
        context: context,
        type: ArtAlertType.warning,
        title: const Text('Categoría requerida'),
        content: const Text('Por favor selecciona una categoría para tu publicación.'),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      await PublicacionesService.crearPublicacion(
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        imagenUrl: _urlImagenController.text.trim(),
        idCategoria: _categoriaSeleccionadaId!,
      );

      if (!mounted) return;
      Navigator.pop(context, true);

      ArtSweetAlert.show(
        context: context,
        type: ArtAlertType.success,
        title: const Text('¡Publicado!'),
        content: const Text('Tu obra ha sido compartida exitosamente.'),
      );
    } catch (e) {
      if (!mounted) return;
      ArtSweetAlert.show(
        context: context,
        type: ArtAlertType.error,
        title: const Text('Error al publicar'),
        content: const Text('La publicacion no se pudo subir, vuelva a intentar'),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomPadding + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nueva Publicación',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryCyan,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),

              // Campo Título
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título de la obra',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Ingresa un título' : null,
              ),
              const SizedBox(height: 15),

              // Selector de Categoría
              _cargandoCategorias
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<int>(
                      value: _categoriaSeleccionadaId,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _categorias.map((cat) {
                        return DropdownMenuItem<int>(
                          value: int.tryParse(cat['id_categoria'].toString()),
                          child: Text(cat['nombre_categoria'].toString()),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _categoriaSeleccionadaId = val),
                      validator: (val) =>
                          val == null ? 'Selecciona una categoría' : null,
                    ),
              const SizedBox(height: 15),

              // Campo URL de Imagen
              TextFormField(
                controller: _urlImagenController,
                decoration: const InputDecoration(
                  labelText: 'URL de la imagen',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Ingresa la URL de la imagen';
                  }
                  if (!val.startsWith('http')) {
                    return 'Ingresa una URL válida (http/https)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Campo Descripción
              TextFormField(
                controller: _descripcionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Ingresa una descripción'
                    : null,
              ),
              const SizedBox(height: 20),

              // Botón Publicar
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryCyan,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _guardando ? null : _publicar,
                  child: _guardando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Publicar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}