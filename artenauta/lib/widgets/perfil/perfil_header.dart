import 'package:flutter/material.dart';
import 'package:artenauta/core/theme/app_theme.dart';

class PerfilHeader extends StatelessWidget {
  final String nombre;
  final String apellido;
  final String email;
  final String inicial;

  final int cantidadObras;
  final int cantidadSeguidores;

  final bool editando;
  final VoidCallback onToggleEditar;

  const PerfilHeader({
    super.key,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.inicial,
    required this.cantidadObras,
    required this.cantidadSeguidores,
    required this.editando,
    required this.onToggleEditar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor:
                  AppTheme.primaryCyan.withValues(
                alpha: 0.15,
              ),
              child: Text(
                inicial,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryCyan,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                _StatItem(
                  valor: cantidadObras.toString(),
                  label: 'Obras',
                ),

                const SizedBox(width: 32),

                _StatItem(
                  valor: cantidadSeguidores.toString(),
                  label: 'Seguidores',
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              '$nombre $apellido',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              email,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onToggleEditar,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppTheme.primaryCyan,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  editando
                      ? 'Cancelar'
                      : 'Editar Perfil',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String valor;
  final String label;

  const _StatItem({
    required this.valor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          valor,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}