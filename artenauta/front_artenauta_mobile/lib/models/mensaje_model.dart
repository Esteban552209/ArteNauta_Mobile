class MensajeModel {
  final int idMensaje;
  final String contenido;
  final DateTime fechaEnvio;
  final int idUsuario;
  final bool leido;

  MensajeModel({
    required this.idMensaje,
    required this.contenido,
    required this.fechaEnvio,
    required this.idUsuario,
    this.leido = false,
  });

  factory MensajeModel.fromJson(Map<String, dynamic> json) {
    return MensajeModel(
      idMensaje: json['id_mensaje'] as int,
      contenido: json['contenido'] ?? '',
      fechaEnvio: DateTime.parse(json['fecha_envio']),
      idUsuario: json['id_usuario'] as int,
      leido: json['leido'] as bool? ?? false,
    );
  }
}