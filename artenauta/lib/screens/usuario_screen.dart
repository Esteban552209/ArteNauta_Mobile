import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme/app_theme.dart';
import '../widgets/gradient_header.dart';

class TestUsuarioScreen extends StatefulWidget {
  const TestUsuarioScreen({super.key});

  @override
  State<TestUsuarioScreen> createState() => _TestUsuarioScreenState();
}

class _TestUsuarioScreenState extends State<TestUsuarioScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Consulta para obtener las publicaciones desde Supabase
  Future<List<Map<String, dynamic>>> _obtenerPublicaciones() async {
    final response = await _supabase
        .from('publicaciones') // Reemplaza por el nombre exacto de tu tabla
        .select('*')
        .eq('estado', true) // Solo mostrar publicaciones activas
        .order('fecha_publicacion', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header ArteNauta
            const GradientHeader(
              height: 60,
              child: Center(
                child: Text(
                  'BIENVENIDO A ARTENAUTA',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

            // Feed de Publicaciones
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _obtenerPublicaciones(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryCyan),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error al cargar publicaciones:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final publicaciones = snapshot.data ?? [];

                  if (publicaciones.isEmpty) {
                    return const Center(
                      child: Text('No hay publicaciones disponibles por el momento.'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12.0),
                      itemCount: publicaciones.length,
                      itemBuilder: (context, index) {
                        final pub = publicaciones[index];
                        return _buildCardPublicacion(pub);
                      },
                    ),
                  );
                },
              ),
            ),

            // Footer
            const GradientHeader(
              height: 30,
              child: Center(
                child: Text(
                  '©2026 ArteNauta',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para renderizar cada tarjeta de publicación
  Widget _buildCardPublicacion(Map<String, dynamic> pub) {
    final titulo = pub['titulo'] ?? 'Sin título';
    final descripcion = pub['descripcion'] ?? pub['contenido'] ?? '';
    final contenidoUrl = pub['contenido']; // Si es una URL de imagen

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado de la tarjeta
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppTheme.primaryCyan,
              child: Icon(Icons.palette, color: Colors.white),
            ),
            title: Text(
              titulo,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              'Categoría: ${pub['id_categoria'] ?? 'General'}',
              style: const TextStyle(fontSize: 12),
            ),
          ),

          // Si el campo contenido contiene una URL de imagen, la muestra
          if (contenidoUrl != null && contenidoUrl.toString().startsWith('http'))
            Image.network(
              contenidoUrl,
              height: 400,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),

          // Descripciones
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              descripcion,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),

          const Divider(height: 1),

          // Zona de interacción (Likes y Comentarios)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Botón de Me Gusta
                TextButton.icon(
                  onPressed: () {
                    // TODO: Conectar a la tabla de Likes en Supabase
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Diste like a "$titulo"')),
                    );
                  },
                  icon: const Icon(Icons.favorite_border, color: Colors.redAccent),
                  label: const Text('Me gusta', style: TextStyle(color: Colors.black87)),
                ),

                // Botón de Comentarios
                TextButton.icon(
                  onPressed: () {
                    // TODO: Abrir modal o pantalla de Comentarios
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ver comentarios de "$titulo"')),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline, color: AppTheme.primaryCyan),
                  label: const Text('Comentar', style: TextStyle(color: Colors.black87)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}