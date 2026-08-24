import 'package:flutter/material.dart';
import '../../widgets/admin_drawer.dart'; 

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Usuarios'),
        backgroundColor: const Color(0xFF134B61),
      ),
      drawer: const AdminDrawer(),
      body: const Center(
        child: Text('Aquí va la tabla de usuarios'),
      ),
    );
  }
}