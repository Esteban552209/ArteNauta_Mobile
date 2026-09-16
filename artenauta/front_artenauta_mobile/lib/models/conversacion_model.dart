class ConversacionModel {
  final int idConversacion;
  final int idUsuarioOtro;
  final String nombreOtro;
  final String? ultimoMensaje;
  final DateTime? fechaUltimoMensaje;
  final int noLeidos;

  ConversacionModel({
    required this.idConversacion,
    required this.idUsuarioOtro,
    required this.nombreOtro,
    this.ultimoMensaje,
    this.fechaUltimoMensaje,
    this.noLeidos = 0,
  });

  String get nombreCompleto => nombreOtro;

  factory ConversacionModel.fromJson(Map<String, dynamic> json) {
    return ConversacionModel(
      idConversacion: json['id_conversacion'] as int,
      idUsuarioOtro: json['id_usuario_otro'] as int,
      nombreOtro: json['nombre_otro'] ?? 'Usuario',
      ultimoMensaje: json['ultimo_mensaje'] as String?,
      fechaUltimoMensaje: json['fecha_ultimo_mensaje'] != null
          ? DateTime.parse(json['fecha_ultimo_mensaje'])
          : null,
      noLeidos: json['no_leidos'] as int? ?? 0,
    );
  }
}