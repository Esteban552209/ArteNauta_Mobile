import 'package:flutter/material.dart';
import 'package:artenauta/core/theme/app_theme.dart';

class PublicacionesPropiasCard extends StatelessWidget {
  final VoidCallback onTapVerPublicaciones;

  const PublicacionesPropiasCard({
    super.key,
    required this.onTapVerPublicaciones,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.primaryCyan.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: const Icon(Icons.collections_outlined, color: AppTheme.primaryCyan),
        title: const Text(
          'Mis Publicaciones',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryCyan,
          ),
        ),
        subtitle: const Text(
          'Gestiona y visualiza tus obras publicadas.',
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primaryCyan),
        onTap: onTapVerPublicaciones,
      ),
    );
  }
}