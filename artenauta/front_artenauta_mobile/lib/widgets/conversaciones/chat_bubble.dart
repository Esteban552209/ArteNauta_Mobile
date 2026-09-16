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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Align(
        alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
              : Text(
                  mensaje.contenido,
                  style: TextStyle(color: esMio ? Colors.white : Colors.black87),
                ),
        ),
      ),
    );
  }
}