class ConversacionModel {
  final int idConversacion;
  final int idUsuarioOtro;
  final String nombreOtro;
  final String apellidoOtro;
  final String emailOtro;
  final String? ultimoMensaje;
  final DateTime? fechaUltimoMensaje;
  final int noLeidos;

  ConversacionModel({
    required this.idConversacion,
    required this.idUsuarioOtro,
    required this.nombreOtro,
    required this.apellidoOtro,
    required this.emailOtro,
    this.ultimoMensaje,
    this.fechaUltimoMensaje,
    this.noLeidos = 0,
  });

  String get nombreCompleto => '$nombreOtro $apellidoOtro'.trim();

  factory ConversacionModel.fromParticipante(
    Map<String, dynamic> json, {
    String? ultimoMensaje,
    DateTime? fechaUltimoMensaje,
    int noLeidos = 0,
  }) {
    final usuario = json['usuarios'] as Map<String, dynamic>? ?? {};
    return ConversacionModel(
      idConversacion: json['id_conversacion'] as int,
      idUsuarioOtro: usuario['id_usuario'] ?? 0,
      nombreOtro: usuario['nombre'] ?? '',
      apellidoOtro: usuario['apellido'] ?? '',
      emailOtro: usuario['email'] ?? '',
      ultimoMensaje: ultimoMensaje,
      fechaUltimoMensaje: fechaUltimoMensaje,
      noLeidos: noLeidos,
    );
  }
}