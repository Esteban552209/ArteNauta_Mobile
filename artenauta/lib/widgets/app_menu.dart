import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class AppMenu extends StatelessWidget {
  final int idRol;
  final VoidCallback? onNuevaPublicacion;
  final VoidCallback? onMiPerfil;
  final VoidCallback? onConversaciones;
  final VoidCallback? onNotificaciones;
  final VoidCallback? onCerrarSesion;

  const AppMenu({
    super.key,
    required this.idRol,
    this.onNuevaPublicacion,
    this.onMiPerfil,
    this.onConversaciones,
    this.onNotificaciones,
    this.onCerrarSesion,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 210,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nueva publicación — solo artista (idRol == 2)
            if (idRol == 2) ...[
              _Item(
                icon: Icons.add_circle_outline,
                label: 'Nueva Publicación',
                color: AppTheme.primaryCyan,
                onTap: onNuevaPublicacion ?? () {},
              ),
              const Divider(height: 1),
            ],

            _Item(
              icon: Icons.person_outline,
              label: 'Mi Perfil',
              color: AppTheme.primaryCyan,
              onTap: onMiPerfil ?? () {},
            ),
            const Divider(height: 1),

            _Item(
              icon: Icons.chat_bubble_outline,
              label: 'Conversaciones',
              color: AppTheme.primaryCyan,
              onTap: onConversaciones ?? () {},
            ),
            const Divider(height: 1),

            _Item(
              icon: Icons.notifications_outlined,
              label: 'Notificaciones',
              color: AppTheme.primaryCyan,
              onTap: onNotificaciones ?? () {},
            ),
            const Divider(height: 1),

            _Item(
              icon: Icons.logout,
              label: 'Cerrar Sesión',
              color: Colors.red,
              onTap: onCerrarSesion ?? () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _Item({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color == Colors.red ? Colors.red : Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}