import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';

class PerfilSolicitudCard extends StatefulWidget {
  final Map<String, dynamic>? usuario;

  const PerfilSolicitudCard({super.key, required this.usuario});

  @override
  State<PerfilSolicitudCard> createState() => _PerfilSolicitudCardState();
}

class _PerfilSolicitudCardState extends State<PerfilSolicitudCard> {
  bool _enviandoSolicitud = false;
  bool _solicitudEnviada = false;
  final _supabase = Supabase.instance.client;

  Future<void> _enviarSolicitud() async {
    setState(() => _enviandoSolicitud = true);
    final idUsuario = int.tryParse(widget.usuario?['id_usuario'].toString() ?? '');

    if (idUsuario == null) {
      setState(() => _enviandoSolicitud = false);
      return;
    }

    try {
      final existente = await _supabase
          .from('solicitudes')
          .select('id_solicitud')
          .eq('id_usuario', idUsuario)
          .eq('tipo_solicitud', 'artista')
          .eq('estado_solicitud', 'Pendiente')
          .maybeSingle();

      if (existente != null) {
        setState(() => _enviandoSolicitud = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ya tienes una solicitud pendiente'), backgroundColor: Colors.orange),
        );
        return;
      }

      await _supabase.from('solicitudes').insert({
        'id_usuario': idUsuario,
        'tipo_solicitud': 'artista',
        'estado_solicitud': 'Pendiente',
        'fecha_solicitud': DateTime.now().toIso8601String(),
      });

      setState(() {
        _enviandoSolicitud = false;
        _solicitudEnviada = true;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Solicitud enviada! El administrador la revisará.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _enviandoSolicitud = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _mostrarDialogo() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Solicitar ser artista?',
            style: TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold, fontSize: 16)),
        content: const Text('Se enviará una solicitud al administrador para cambiar tu rol.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.red))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _enviarSolicitud();
            },
            child: const Text('Sí, solicitar', style: TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

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
                Text('¿Quieres ser Artista?', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryCyan)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Solicita el cambio de rol al administrador.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 12),
            if (_solicitudEnviada)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('¡Solicitud enviada! El administrador revisará tu solicitud.',
                          style: TextStyle(fontSize: 12, color: Colors.green)),
                    ),
                  ],
                ),
              )
            else
              GestureDetector(
                onTap: _enviandoSolicitud ? null : _mostrarDialogo,
                child: Text(
                  _enviandoSolicitud ? 'Enviando...' : 'Solicitar ser Artista',
                  style: TextStyle(
                    color: _enviandoSolicitud ? Colors.grey : AppTheme.primaryCyan,
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