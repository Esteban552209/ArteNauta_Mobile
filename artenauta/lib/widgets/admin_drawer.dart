import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/session_service.dart';
import '../screens/login_screen.dart';
import '../screens/admin/gestion_usuarios_screen.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  void _cerrarSesion(BuildContext context) async {
    await SessionService.cerrarSesion();
    
    if (!context.mounted) return;
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false, 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1A5F7A),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF134B61), 
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ArteNauta',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context), 
                )
              ],
            ),
          ),
          
          _buildMenuItem(
            title: 'Usuarios',
            svgPath: 'assets/icons/usuarios.svg',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GestionUsuariosScreen()),
              );
            },
          ),
          _buildMenuItem(
            title: 'Publicaciones',
            svgPath: 'assets/icons/publicaciones.svg',
            onTap: () {},
          ),
          _buildMenuItem(
            title: 'Comentarios',
            svgPath: 'assets/icons/comentarios.svg',
            onTap: () {},
          ),
          
          const Divider(color: Colors.white54),
          
          _buildMenuItem(
            title: 'Cerrar Sesión',
            svgPath: 'assets/icons/log_out.svg',
            onTap: () => _cerrarSesion(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({required String title, required String svgPath, required VoidCallback onTap}) {
    return ListTile(
      leading: SvgPicture.asset(
        svgPath,
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn), 
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: onTap,
    );
  }
}