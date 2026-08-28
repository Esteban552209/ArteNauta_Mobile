class ConversacionModel {
  final int idConversacion;
  final int idUsuarioOtro;
  final String nombreOtro;
  final String apellidoOtro;
  final String emailOtro;

  ConversacionModel({
    required this.idConversacion,
    required this.idUsuarioOtro,
    required this.nombreOtro,
    required this.apellidoOtro,
    required this.emailOtro,
  });

  String get nombreCompleto => '$nombreOtro $apellidoOtro'.trim();

  factory ConversacionModel.fromParticipante(Map<String, dynamic> json) {
    final usuario = json['usuarios'] as Map<String, dynamic>? ?? {};
    return ConversacionModel(
      idConversacion: json['id_conversacion'] as int,
      idUsuarioOtro: usuario['id_usuario'] ?? 0,
      nombreOtro: usuario['nombre'] ?? '',
      apellidoOtro: usuario['apellido'] ?? '',
      emailOtro: usuario['email'] ?? '',
    );
  }
}