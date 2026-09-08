import 'package:flutter/material.dart';
import '../services/publicaciones_service.dart';
import '../widgets/gradient_header.dart';
import '../widgets/perfil/mis_publicaciones_list.dart';

class PerfilPublicacionesScreen extends StatefulWidget {
  final int idUsuario;

  const PerfilPublicacionesScreen({super.key, required this.idUsuario});

  @override
  State<PerfilPublicacionesScreen> createState() => _PerfilPublicacionesScreenState();
}

class _PerfilPublicacionesScreenState extends State<PerfilPublicacionesScreen> {
  List<Map<String, dynamic>> _publicaciones = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPublicaciones();
  }

  Future<void> _cargarPublicaciones() async {
    setState(() => _cargando = true);
    try {
      final pubs = await PublicacionesService.getPublicacionesPorUsuario(widget.idUsuario);
      setState(() {
        _publicaciones = pubs;
        _cargando = false;
      });
    } catch (_) {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            GradientHeader(
              height: 100,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mis Publicaciones',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),

            // Contenido
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: MisPublicacionesList(
                  publicaciones: _publicaciones,
                  cargando: _cargando,
                  onRefresh: _cargarPublicaciones,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}