import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/publicaciones_service.dart';

class EditarPublicacionDialog extends StatefulWidget {
  final Map<String, dynamic> publicacion;
  final VoidCallback onSuccess;

  const EditarPublicacionDialog({
    super.key,
    required this.publicacion,
    required this.onSuccess,
  });

  @override
  State<EditarPublicacionDialog> createState() => _EditarPublicacionDialogState();
}

class _EditarPublicacionDialogState extends State<EditarPublicacionDialog> {
  late TextEditingController _tituloCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _precioCtrl;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _tituloCtrl = TextEditingController(text: widget.publicacion['titulo'] ?? '');
    _descCtrl = TextEditingController(text: widget.publicacion['descripcion'] ?? '');
    _precioCtrl = TextEditingController(text: widget.publicacion['precio']?.toString() ?? '');
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final idPub = int.tryParse(widget.publicacion['id_publicacion'].toString());
    if (idPub == null) return;

    setState(() => _guardando = true);
    try {
      await PublicacionesService.editarPublicacion(
        idPublicacion: idPub,
        titulo: _tituloCtrl.text.trim(),
        descripcion: _descCtrl.text.trim(),
        precio: double.tryParse(_precioCtrl.text.trim()),
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publicación actualizada'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => _guardando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Editar Publicación',
          style: TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _tituloCtrl,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _precioCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Precio (Opcional)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _guardando ? null : _guardar,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryCyan),
          child: _guardando
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Guardar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}