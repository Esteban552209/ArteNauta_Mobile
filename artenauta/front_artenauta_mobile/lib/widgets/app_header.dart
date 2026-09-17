import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/publicaciones/publicacion_search_delegate.dart';

class AppHeader extends StatelessWidget {
  final String inicial;
  final int notifCount;
  final List<dynamic> publicaciones;
  final VoidCallback onNotificacionesPressed;
  final VoidCallback onAvatarPressed;

  const AppHeader({
    super.key,
    required this.inicial,
    required this.notifCount,
    this.publicaciones = const [],
    required this.onNotificacionesPressed,
    required this.onAvatarPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/LOGO.png',
                height: 90,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 9),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Colors.black87,
                  size: 32,
                ),
                tooltip: 'Buscar publicaciones',
                onPressed: () {
                  final listaMapeada = publicaciones
                      .map((e) => e as Map<String, dynamic>)
                      .toList();

                  showSearch(
                    context: context,
                    delegate: PublicacionSearchDelegate(
                      publicaciones: listaMapeada,
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.black87,
                      size: 36,
                    ),
                    onPressed: onNotificacionesPressed,
                  ),
                  if (notifCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$notifCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onAvatarPressed,
                child: CircleAvatar(
                  radius: 23,
                  backgroundColor: AppTheme.primaryCyan.withValues(alpha: 0.15),
                  child: Text(
                    inicial,
                    style: const TextStyle(
                      color: AppTheme.primaryCyan,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}