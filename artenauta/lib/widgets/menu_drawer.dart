import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/auth_service.dart';

class MenuDrawer extends StatelessWidget {
  final int idRol;
  final VoidCallback? onNuevaPublicacion;
  final VoidCallback? onMiPerfil;
  final VoidCallback? onNotificaciones;
  final VoidCallback? onCerrarSesion;

  const MenuDrawer({
    super.key,
    required this.idRol,
    this.onNuevaPublicacion,
    this.onMiPerfil,
    this.onNotificaciones,
    this.onCerrarSesion,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.darkCyan, AppTheme.primaryCyan],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/LOGO.png', height: 60),
                  const SizedBox(height: 8),
                  Text(
                    idRol == 3
                        ? 'Panel Admin'
                        : idRol == 2
                            ? 'Panel Artista'
                            : 'Panel Usuario',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (idRol == 2)
              _MenuItem(
                icono: Icons.add_circle_outline,
                texto: 'Nueva Publicación',
                onTap: () {
                  Navigator.pop(context);
                  onNuevaPublicacion?.call();
                },
              ),
            _MenuItem(
              icono: Icons.person_outline,
              texto: 'Mi Perfil',
              onTap: () {
                Navigator.pop(context);
                onMiPerfil?.call();
              },
            ),
            _MenuItem(
              icono: Icons.notifications_outlined,
              texto: 'Notificaciones',
              onTap: () {
                Navigator.pop(context);
                onNotificaciones?.call();
              },
            ),
            const Spacer(),
            const Divider(),
            _MenuItem(
              icono: Icons.logout,
              texto: 'Cerrar Sesión',
              color: Colors.red,
              onTap: () async {
                Navigator.pop(context);
                await AuthService.cerrarSesion();
                onCerrarSesion?.call();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icono;
  final String texto;
  final VoidCallback onTap;
  final Color? color;

  const _MenuItem({
    required this.icono,
    required this.texto,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icono, color: color ?? AppTheme.primaryCyan),
      title: Text(
        texto,
        style: TextStyle(
          color: color ?? AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}