import 'package:flutter/material.dart';
import 'package:artenauta/core/theme/app_theme.dart';

class SolicitudRolCard extends StatelessWidget {
  final bool enviandoSolicitud;
  final bool solicitudEnviada;
  final VoidCallback onSolicitar;

  const SolicitudRolCard({
    super.key,
    required this.enviandoSolicitud,
    required this.solicitudEnviada,
    required this.onSolicitar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.primaryCyan.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.brush_outlined, color: AppTheme.primaryCyan, size: 20),
                SizedBox(width: 8),
                Text(
                  '¿Quieres ser Artista?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryCyan,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Solicita el cambio de rol al administrador.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            if (solicitudEnviada)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.green.shade600,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '¡Solicitud enviada! El administrador revisará tu solicitud.',
                        style: TextStyle(fontSize: 12, color: Colors.green),
                      ),
                    ),
                  ],
                ),
              )
            else
              GestureDetector(
                onTap: enviandoSolicitud ? null : onSolicitar,
                child: Text(
                  enviandoSolicitud ? 'Enviando...' : 'Solicitar ser Artista',
                  style: TextStyle(
                    color: enviandoSolicitud ? Colors.grey : AppTheme.primaryCyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}