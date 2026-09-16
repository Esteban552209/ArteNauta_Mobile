import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/conversacion_model.dart';

class ConversacionItem extends StatelessWidget {
  final ConversacionModel conversacion;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ConversacionItem({
    super.key,
    required this.conversacion,
    required this.onTap,
    required this.onLongPress,
  });

  String _formatoFecha(DateTime? fecha) {
    if (fecha == null) return '';
    final ahora = DateTime.now();
    final esHoy = fecha.year == ahora.year &&
        fecha.month == ahora.month &&
        fecha.day == ahora.day;
    if (esHoy) {
      final hora = fecha.hour.toString().padLeft(2, '0');
      final min = fecha.minute.toString().padLeft(2, '0');
      return '$hora:$min';
    }
    final ayer = ahora.subtract(const Duration(days: 1));
    final esAyer = fecha.year == ayer.year &&
        fecha.month == ayer.month &&
        fecha.day == ayer.day;
    if (esAyer) return 'Ayer';
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final c = conversacion;
    final tieneNoLeidos = c.noLeidos > 0;

    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(
        c.nombreCompleto,
        style: TextStyle(
          fontWeight: tieneNoLeidos ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: c.ultimoMensaje == null
          ? null
          : Text(
              c.ultimoMensaje!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: tieneNoLeidos ? Colors.black87 : Colors.grey,
                fontWeight: tieneNoLeidos ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatoFecha(c.fechaUltimoMensaje),
            style: TextStyle(
              fontSize: 12,
              color: tieneNoLeidos ? AppTheme.primaryCyan : Colors.grey,
              fontWeight: tieneNoLeidos ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          if (tieneNoLeidos)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryCyan,
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: const BoxConstraints(minWidth: 20),
              child: Text(
                c.noLeidos > 99 ? '99+' : '${c.noLeidos}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}