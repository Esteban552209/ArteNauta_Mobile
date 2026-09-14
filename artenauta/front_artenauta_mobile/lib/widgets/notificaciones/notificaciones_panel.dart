import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/gradient_header.dart';
import '../../services/session_service.dart';
import '../../services/notificaciones_service.dart';

class NotificacionesPanel extends StatefulWidget {
  const NotificacionesPanel({super.key});

  @override
  State<NotificacionesPanel> createState() => _NotificacionesPanelState();
}

class _NotificacionesPanelState extends State<NotificacionesPanel> {
  final _service = NotificacionesService();
  List<Map<String, dynamic>> _notificaciones = [];
  List<Map<String, dynamic>> _solicitudes = [];
  bool _cargando = true;
  int _idRol = 1;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final rol = await SessionService.getRol();
    setState(() => _idRol = rol ?? 1);

    try {
      final notifs = await _service.getNotificaciones();
      final sols = _idRol == 3
          ? await _service.getSolicitudes()
          : <Map<String, dynamic>>[];

      await _service.marcarComoVistas();

      setState(() {
        _notificaciones = notifs;
        _solicitudes = sols;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  Future<void> _aprobar(Map<String, dynamic> sol) async {
    try {
      await _service.aprobarSolicitud(
        idSolicitud: sol['id_solicitud'] as int,
        idUsuario: sol['id_usuario'] as int,
      );
      setState(() => _solicitudes
          .removeWhere((s) => s['id_solicitud'] == sol['id_solicitud']));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Solicitud aprobada'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _rechazar(Map<String, dynamic> sol) async {
    try {
      await _service.rechazarSolicitud(
        idSolicitud: sol['id_solicitud'] as int,
        idUsuario: sol['id_usuario'] as int,
      );
      setState(() => _solicitudes
          .removeWhere((s) => s['id_solicitud'] == sol['id_solicitud']));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Solicitud rechazada'),
            backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _tiempoRelativo(String? fecha) {
    if (fecha == null) return '';
    final fechaLocal = DateTime.parse(fecha).toLocal();
    final diff = DateTime.now().difference(fechaLocal);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    return 'Hace ${diff.inDays}d';
  }

  IconData _iconoPorTipo(String? tipo) {
    switch (tipo) {
      case 'solicitud_aprobada': return Icons.check_circle_outline;
      case 'solicitud_rechazada': return Icons.cancel_outlined;
      case 'advertencia': return Icons.warning_amber_outlined;
      case 'Mensaje': return Icons.message_outlined;
      case 'Reaccion': return Icons.favorite_outline;
      case 'Comentario': return Icons.comment_outlined;
      case 'Informativo': return Icons.info_outline;
      default: return Icons.notifications_outlined;
    }
  }

  Color _colorPorTipo(String? tipo) {
    switch (tipo) {
      case 'solicitud_aprobada': return Colors.green;
      case 'solicitud_rechazada': return Colors.red;
      case 'advertencia': return Colors.orange;
      case 'Reaccion': return Colors.red;
      case 'Comentario': return Colors.blue;
      case 'Mensaje': return AppTheme.primaryCyan;
      case 'Informativo': return Colors.purple;
      default: return AppTheme.primaryCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GradientHeader(
              height: 90,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text('Notificaciones',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _cargar,
                      child: _notificaciones.isEmpty && _solicitudes.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.notifications_off_outlined,
                                      size: 64, color: Colors.grey),
                                  SizedBox(height: 12),
                                  Text('Sin notificaciones',
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            )
                          : ListView(
                              children: [
                                if (_idRol == 3 &&
                                    _solicitudes.isNotEmpty) ...[
                                  const Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(16, 16, 16, 8),
                                    child: Text('Solicitudes pendientes',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryCyan)),
                                  ),
                                  ..._solicitudes.map((sol) {
                                    final nombre =
                                        '${sol['usuarios']?['nombre'] ?? ''} ${sol['usuarios']?['apellido'] ?? ''}';
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(children: [
                                              const Icon(Icons.access_time,
                                                  color: AppTheme.primaryCyan,
                                                  size: 20),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                  child: Text(
                                                      '$nombre quiere ser artista',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold))),
                                            ]),
                                            const SizedBox(height: 4),
                                            Text(
                                                _tiempoRelativo(
                                                    sol['fecha_solicitud']
                                                        as String?),
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12)),
                                            const SizedBox(height: 10),
                                            Row(children: [
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  onPressed: () =>
                                                      _aprobar(sol),
                                                  icon: const Icon(Icons.check,
                                                      size: 16),
                                                  label:
                                                      const Text('Aprobar'),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.green,
                                                    foregroundColor:
                                                        Colors.white,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  onPressed: () =>
                                                      _rechazar(sol),
                                                  icon: const Icon(Icons.close,
                                                      size: 16),
                                                  label:
                                                      const Text('Rechazar'),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.red,
                                                    foregroundColor:
                                                        Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ]),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                  const Divider(),
                                ],
                                if (_notificaciones.isNotEmpty) ...[
                                  const Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(16, 8, 16, 8),
                                    child: Text('Recientes',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryCyan)),
                                  ),
                                  ..._notificaciones.map((n) {
                                    final tipo =
                                        n['tipo_notificacion'] as String?;
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: _colorPorTipo(tipo)
                                            .withValues(alpha: 0.15),
                                        child: Icon(_iconoPorTipo(tipo),
                                            color: _colorPorTipo(tipo),
                                            size: 20),
                                      ),
                                      title: Text(n['asunto'] ?? '',
                                          style: const TextStyle(
                                              fontSize: 14)),
                                      subtitle: Text(
                                          _tiempoRelativo(
                                              n['fecha_notificacion']
                                                  as String?),
                                          style: const TextStyle(
                                              fontSize: 12)),
                                    );
                                  }),
                                ],
                              ],
                            ),
                    ),
            ),
            const GradientHeader(
              height: 35,
              child: Center(
                child: Text('©2026 ArteNauta',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}