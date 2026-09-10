import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../screens/perfil_screen.dart';
import '../screens/conversaciones_screen.dart';

class AppMenu extends StatelessWidget {
  final int idRol;
  final int notifCount;
  final VoidCallback onNotificacionesTap;
  final VoidCallback onCerrarSesion;

  const AppMenu({
    super.key,
    required this.idRol,
    required this.notifCount,
    required this.onNotificacionesTap,
    required this.onCerrarSesion,
  });

  static void mostrar(
    BuildContext context, {
    required int idRol,
    required int notifCount,
    required VoidCallback onNotificacionesTap,
    required VoidCallback onCerrarSesion,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      elevation: 10,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return AppMenu(
          idRol: idRol,
          notifCount: notifCount,
          onNotificacionesTap: onNotificacionesTap,
          onCerrarSesion: onCerrarSesion,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppTheme.primaryCyan,
                child: Icon(Icons.person_outline, color: Colors.white, size: 30),
              ),
              title: const Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PerfilScreen()),
                );
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppTheme.primaryCyan,
                child: Icon(Icons.chat_bubble_outline, color: Colors.white, size: 30),
              ),
              title: const Text('Conversaciones', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ConversacionesScreen()),
                );
              },
            ),
            ListTile(
              leading: Stack(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppTheme.primaryCyan,
                    child: Icon(Icons.notifications_none, color: Colors.white, size: 30),
                  ),
                  if (notifCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: CircleAvatar(
                        radius: 6,
                        backgroundColor: Colors.red,
                        child: Text(
                          '$notifCount',
                          style: const TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              title: const Text('Notificaciones', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                Navigator.pop(context);
                onNotificacionesTap();
              },
            ),
            const Divider(height: 24),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red.shade50,
                child: const Icon(Icons.logout, color: Colors.red, size: 30),
              ),
              title: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                onCerrarSesion();
              },
            ),
          ],
        ),
      ),
    );
  }
}