import 'package:flutter/material.dart';

class TestUsuarioScreen extends StatelessWidget {
  const TestUsuarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vista USUARIO (Rol 3)')),
      backgroundColor: Colors.blue.shade100,
      body: const Center(
        child: Text('¡Bienvenido Usuario de ArteNauta!', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,)),
      ),
    );
  }
}