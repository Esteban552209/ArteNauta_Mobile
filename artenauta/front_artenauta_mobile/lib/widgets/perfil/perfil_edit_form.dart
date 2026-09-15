import 'package:flutter/material.dart';
import 'package:artenauta/core/theme/app_theme.dart';

class PerfilEditForm extends StatelessWidget {
  final TextEditingController nombreController;
  final TextEditingController apellidoController;
  final TextEditingController telefonoController;
  final VoidCallback onGuardar;

  const PerfilEditForm({
    super.key,
    required this.nombreController,
    required this.apellidoController,
    required this.telefonoController,
    required this.onGuardar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Editar información',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppTheme.primaryCyan,
              ),
            ),
            const SizedBox(height: 16),
            _CampoTexto(
              label: 'Nombre',
              controller: nombreController,
              icono: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            _CampoTexto(
              label: 'Apellido',
              controller: apellidoController,
              icono: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            _CampoTexto(
              label: 'Teléfono',
              controller: telefonoController,
              icono: Icons.phone_outlined,
              tipo: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onGuardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryCyan,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Guardar cambios'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampoTexto extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icono;
  final TextInputType tipo;

  const _CampoTexto({
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.primaryCyan, width: 2),
        ),
      ),
    );
  }
}