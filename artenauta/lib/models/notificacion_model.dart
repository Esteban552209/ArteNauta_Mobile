class NotificacionModel {
  final int idNotificacion;
  final int idUsuario;
  final String asunto;
  final String tipoNotificacion;
  final bool leida;
  final DateTime fechaNotificacion;

  NotificacionModel({
    required this.idNotificacion,
    required this.idUsuario,
    required this.asunto,
    required this.tipoNotificacion,
    required this.leida,
    required this.fechaNotificacion,
  });

  factory NotificacionModel.fromJson(Map<String, dynamic> json) {
    return NotificacionModel(
      idNotificacion: json['id_notificacion'] ?? 0,
      idUsuario: json['id_usuario'] ?? 0,
      asunto: json['asunto'] ?? '',
      tipoNotificacion: json['tipo_notificacion'] ?? '',
      leida: json['leida'] ?? false,
      fechaNotificacion: DateTime.parse(
        json['fecha_notificacion'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}