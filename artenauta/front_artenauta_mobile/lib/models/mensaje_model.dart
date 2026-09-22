class MensajeModel {
  final int idMensaje;
  final String contenido;
  final DateTime fechaEnvio;
  final int idUsuario;
  final bool leido;
  final bool eliminadoTodos;

  MensajeModel({
    required this.idMensaje,
    required this.contenido,
    required this.fechaEnvio,
    required this.idUsuario,
    this.leido = false,
    this.eliminadoTodos = false,
  });

  factory MensajeModel.fromJson(Map<String, dynamic> json) {
    return MensajeModel(
      idMensaje: json['id_mensaje'] as int,
      contenido: json['contenido'] ?? '',
      // El backend guarda en UTC; .toLocal() hora real del dispositivo
      fechaEnvio: DateTime.parse(json['fecha_envio']).toLocal(),
      idUsuario: json['id_usuario'] as int,
      leido: json['leido'] as bool? ?? false,
      eliminadoTodos: json['eliminado_todos'] as bool? ?? false,
    );
  }
}