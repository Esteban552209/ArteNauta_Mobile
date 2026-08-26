import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

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
                  onPressed: () => Navigator.pop(context), // Cierra el menú
                )
              ],
            ),
          ),
          
          _buildMenuItem(
            title: 'Usuarios',
            svgPath: 'assets/icons/users.svg',
            onTap: () {
            },
          ),
          _buildMenuItem(
            title: 'Publicaciones',
            svgPath: 'assets/icons/posts.svg',
            onTap: () {},
          ),
          _buildMenuItem(
            title: 'Comentarios',
            svgPath: 'assets/icons/comments.svg',
            onTap: () {},
          ),
          
          const Divider(color: Colors.white54),
          
          _buildMenuItem(
            title: 'Cerrar Sesión',
            svgPath: 'assets/icons/logout.svg',
            onTap: () {
            },
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
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn), // Pinta el SVG de blanco
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: onTap,
    );
  }
}