import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class FiltrosUsuariosDialog extends StatefulWidget {
  final String? estadoActual;
  final String? rolActual;

  const FiltrosUsuariosDialog({
    super.key,
    this.estadoActual,
    this.rolActual,
  });

  @override
  State<FiltrosUsuariosDialog> createState() => _FiltrosUsuariosDialogState();
}

class _FiltrosUsuariosDialogState extends State<FiltrosUsuariosDialog> {
  String? _filtroEstado;
  String? _filtroRol;

  @override
  void initState() {
    super.initState();
    _filtroEstado = widget.estadoActual;
    _filtroRol = widget.rolActual;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filtrar Usuarios', style: TextStyle(color: AppTheme.primaryCyan)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String?>(
            initialValue: _filtroEstado,
            decoration: const InputDecoration(labelText: 'Estado de Cuenta'),
            items: const [
              DropdownMenuItem(value: null, child: Text('Todos')),
              DropdownMenuItem(value: 'true', child: Text('Activos')),
              DropdownMenuItem(value: 'false', child: Text('Inactivos')),
            ],
            onChanged: (val) => setState(() => _filtroEstado = val),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String?>(
            initialValue: _filtroRol,
            decoration: const InputDecoration(labelText: 'Rol de Usuario'),
            items: const [
              DropdownMenuItem(value: null, child: Text('Todos')),
              DropdownMenuItem(value: '1', child: Text('Usuario Final')),
              DropdownMenuItem(value: '2', child: Text('Artista')),
              DropdownMenuItem(value: '3', child: Text('Administrador')),
            ],
            onChanged: (val) => setState(() => _filtroRol = val),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Devolvemos un mapa con valores nulos para limpiar el filtro
            Navigator.pop(context, {'estado': null, 'rol': null});
          },
          child: const Text('Limpiar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryCyan),
          onPressed: () {
            // Devolvemos los valores seleccionados
            Navigator.pop(context, {'estado': _filtroEstado, 'rol': _filtroRol});
          },
          child: const Text('Aplicar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}