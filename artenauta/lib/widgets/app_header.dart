import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/session_service.dart';

class AppHeader extends StatelessWidget {
  final int idRol;
  final String nombre;
  final bool menuAbierto;
  final VoidCallback onMenuTap;

  const AppHeader({
    super.key,
    required this.idRol,
    required this.nombre,
    required this.menuAbierto,
    required this.onMenuTap, required int notifCount,
  });

  String get _tituloPanel {
    switch (idRol) {
      case 3: return 'Panel Admin';
      case 2: return 'Panel Artista';
      default: return 'Panel Usuario';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.darkCyan, AppTheme.primaryCyan],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset('assets/LOGO.png', height: 70, fit: BoxFit.contain),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _tituloPanel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Bienvenido, $nombre',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: onMenuTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: menuAbierto ? Colors.white : Colors.transparent,
                  foregroundColor: menuAbierto ? AppTheme.primaryCyan : Colors.white,
                  elevation: 0,
                  side: const BorderSide(color: Colors.white, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Menú',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}