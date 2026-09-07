import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/notificaciones_service.dart';
import 'package:art_sweetalert_new/art_sweetalert_new.dart';

class AppMenu extends StatelessWidget {
  final int idRol;
  final int notifCount; 
  final VoidCallback? onNuevaPublicacion;
  final VoidCallback? onMiPerfil;
  final VoidCallback? onConversaciones;
  final VoidCallback? onNotificaciones;
  final VoidCallback? onCerrarSesion;

  const AppMenu({
    super.key,
    required this.idRol,
    this.notifCount = 0, 
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

            InkWell(
              onTap: onNotificaciones ?? () {},
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 13),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(Icons.notifications_outlined,
                            color: AppTheme.primaryCyan, size: 20),
                        if (notifCount > 0)
                          Positioned(
                            top: -6,
                            right: -6,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                notifCount > 9 ? '9+' : '$notifCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Notificaciones',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),

            const Divider(height: 1),
            _Item(
              icon: Icons.logout,
              label: 'Cerrar Sesión',
              color: Colors.red,

              onTap: () {

                ArtSweetAlert.show(
                  context: context,
                  type: ArtAlertType.warning,

                  title: const Text(
                    '¿Cerrar sesión?',
                  ),

                  content: const Text(
                    '¿Estás seguro de que deseas cerrar tu sesión?',
                  ),

                  actions: [

                    // CANCELAR
                    ArtAlertButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      backgroundColor: Colors.grey,
                      textColor: Colors.white,

                      child: const Text(
                        'Cancelar',
                      ),
                    ),

                    ArtAlertButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (onCerrarSesion != null) {
                          onCerrarSesion!();
                        }
                      },
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      child: const Text(
                        'Cerrar sesión',
                      ),
                    ),
                  ],
                );
              },
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
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),

        child: Row(
          children: [

            Icon(
              icon,
              color: color,
              size: 20,
            ),

            const SizedBox(width: 12),

            Text(
              label,
              style: TextStyle(
                color: color == Colors.red
                    ? Colors.red
                    : Colors.black87,
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