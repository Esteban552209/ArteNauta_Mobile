import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/notificacion_model.dart';
import '../../services/auth_service.dart';
import '../../services/notificacion_service.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  List<NotificacionModel> _notificaciones = [];
  bool _cargando = true;
  String? _token;
  int? _idUsuario;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    _token = await AuthService.obtenerToken();
    _idUsuario = await AuthService.obtenerIdUsuario();

    if (_token == null || _idUsuario == null) return;

    final data = await NotificacionService.obtener(_idUsuario!, _token!);

    // Marcar todas como leídas al abrir
    await NotificacionService.marcarTodasLeidas(_token!);

    setState(() {
      _notificaciones = data;
      _cargando = false;
    });
  }

  IconData _iconoPorTipo(String tipo) {
    switch (tipo) {
      case 'solicitud_aprobada':
        return Icons.check_circle_outline;
      case 'solicitud_rechazada':
        return Icons.cancel_outlined;
      case 'like_publicacion':
        return Icons.favorite_outline;
      case 'comentario_publicacion':
        return Icons.chat_bubble_outline;
      case 'advertencia':
        return Icons.warning_amber_outlined;
      case 'censura_obra':
        return Icons.block_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _colorPorTipo(String tipo) {
    switch (tipo) {
      case 'solicitud_aprobada':
        return Colors.green;
      case 'solicitud_rechazada':
        return Colors.red;
      case 'like_publicacion':
        return Colors.red.shade400;
      case 'comentario_publicacion':
        return AppTheme.primaryCyan;
      case 'advertencia':
        return Colors.orange;
      case 'censura_obra':
        return Colors.red.shade800;
      default:
        return AppTheme.primaryCyan;
    }
  }

  String _tiempoRelativo(DateTime fecha) {
    final diff = DateTime.now().difference(fecha);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    return 'Hace ${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: AppTheme.primaryCyan,
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _notificaciones.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined,
                          size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      const Text(
                        'Sin notificaciones',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notificaciones.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final n = _notificaciones[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: n.leida
                              ? Colors.white
                              : AppTheme.primaryCyan.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: n.leida
                                ? Colors.grey.shade200
                                : AppTheme.primaryCyan.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _colorPorTipo(n.tipoNotificacion)
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _iconoPorTipo(n.tipoNotificacion),
                                color: _colorPorTipo(n.tipoNotificacion),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    n.asunto,
                                    style: TextStyle(
                                      fontWeight: n.leida
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                      fontSize: 13,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _tiempoRelativo(n.fechaNotificacion),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!n.leida)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryCyan,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}