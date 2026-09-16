import 'package:flutter/material.dart';

class BuscadorUsuarioItem extends StatelessWidget {
  final Map<String, dynamic> usuario;
  final VoidCallback onTap;

  const BuscadorUsuarioItem({
    super.key,
    required this.usuario,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nombre = '${usuario['nombre']} ${usuario['apellido']}';
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(nombre),
      subtitle: Text(usuario['email'] ?? ''),
      onTap: onTap,
    );
  }
}