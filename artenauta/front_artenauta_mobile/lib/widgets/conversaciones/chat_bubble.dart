import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/mensaje_model.dart';

class ChatBubble extends StatelessWidget {
  final MensajeModel mensaje;
  final bool esMio;
  final VoidCallback onLongPress;

  const ChatBubble({
    super.key,
    required this.mensaje,
    required this.esMio,
    required this.onLongPress,
  });

  String _hora(DateTime fecha) {
    final h = fecha.hour.toString().padLeft(2, '0');
    final m = fecha.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Align(
        alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: mensaje.eliminadoTodos
                ? Colors.grey[300]
                : (esMio ? AppTheme.primaryCyan : Colors.grey[200]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: mensaje.eliminadoTodos
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.block, size: 14, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(
                      'Se eliminó este mensaje',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mensaje.contenido,
                      style: TextStyle(color: esMio ? Colors.white : Colors.black87),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _hora(mensaje.fechaEnvio),
                      style: TextStyle(
                        fontSize: 10,
                        color: esMio ? Colors.white70 : Colors.black45,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}