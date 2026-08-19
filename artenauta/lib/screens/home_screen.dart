import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/gradient_header.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header con degradado, nombre de app y botón de Perfil
            GradientHeader(
              height: 70,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ARTENAUTA',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 2,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.account_circle, color: Colors.white, size: 30),
                      tooltip: 'Mi Perfil',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Contenido Principal (Feed de publicaciones o proyectos)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  const Text(
                    'Explora Galería',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryCyan,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tarjeta de ejemplo para la galería de arte
                  _buildArtCard(
                    title: 'Obras Recientes',
                    author: 'Comunidad de Artistas',
                    description: 'Descubre las publicaciones más destacadas del día.',
                    icon: Icons.palette_outlined,
                  ),
                  const SizedBox(height: 16),

                  _buildArtCard(
                    title: 'Categorías Populares',
                    author: 'Ilustración, Modelado 3D, Arte Digital',
                    description: 'Filtra el contenido según tus intereses creativos.',
                    icon: Icons.category_outlined,
                  ),
                ],
              ),
            ),

            // Footer con marca de agua
            const GradientHeader(
              height: 35,
              child: Center(
                child: Text(
                  '©2026 ArteNauta',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper para construir tarjetas con el estilo visual consistente
  Widget _buildArtCard({
    required String title,
    required String author,
    required String description,
    required IconData icon,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppTheme.primaryCyan.withOpacity(0.15),
              child: Icon(icon, color: AppTheme.primaryCyan, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    author,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}