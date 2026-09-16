import 'package:flutter/material.dart';

Future<String?> mostrarOpcionesMensaje(BuildContext context, {required bool esMio}) {
  return showModalBottomSheet<String>(
    context: context,
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Eliminar para mí'),
            onTap: () => Navigator.pop(context, 'mi'),
          ),
          if (esMio)
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Eliminar para todos', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context, 'todos'),
            ),
        ],
      ),
    ),
  );
}