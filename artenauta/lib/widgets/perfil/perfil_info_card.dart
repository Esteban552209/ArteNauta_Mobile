import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PerfilInfoCard extends StatefulWidget {
  final Map<String, dynamic>? usuario;
  final TextEditingController nombreController;
  final TextEditingController apellidoController;
  final TextEditingController telefonoController;
  final VoidCallback onGuardar;

  const PerfilInfoCard({
    super.key,
    required this.usuario,
    required this.nombreController,
    required this.apellidoController,
    required this.telefonoController,
    required this.onGuardar,
  });

  @override
  State<PerfilInfoCard> createState() => _PerfilInfoCardState();
}

class _PerfilInfoCardState extends State<PerfilInfoCard> {
  bool _editando = false;

  @override
  Widget build(BuildContext context) {
    final nombre = widget.usuario?['nombre'] ?? 'Usuario';
    final apellido = widget.usuario?['apellido'] ?? '';
    final email = widget.usuario?['email'] ?? '';
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.primaryCyan.withValues(alpha: 0.15),
              child: Text(
                inicial,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryCyan),
              ),
            ),
            const SizedBox(height: 12),
            Text('$nombre $apellido', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(email, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => setState(() => _editando = !_editando),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryCyan,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(_editando ? 'Cancelar' : 'Editar Perfil'),
              ),
            ),

            if (_editando) ...[
              const Divider(height: 32),
              _Campo(label: 'Nombre', controller: widget.nombreController, icono: Icons.person_outline),
              const SizedBox(height: 12),
              _Campo(label: 'Apellido', controller: widget.apellidoController, icono: Icons.person_outline),
              const SizedBox(height: 12),
              _Campo(
                label: 'Teléfono',
                controller: widget.telefonoController,
                icono: Icons.phone_outlined,
                tipo: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onGuardar();
                    setState(() => _editando = false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Guardar cambios'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icono;
  final TextInputType tipo;

  const _Campo({
    required this.label,
    required this.controller,
    required this.icono,
    this.tipo = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: tipo,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icono, color: AppTheme.primaryCyan),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}