import 'package:flutter/material.dart';

class TestArtistaScreen extends StatelessWidget {
  const TestArtistaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vista ARTISTA (Rol 2)')),
      backgroundColor: Colors.green.shade100,
      body: const Center(
        child: Text('¡Bienvenido Artista!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
    );
  }
}