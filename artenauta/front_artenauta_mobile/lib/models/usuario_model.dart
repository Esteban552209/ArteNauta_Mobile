    class UsuarioModel {
  final int idUsuario;
  final String nombre;
  final String apellido;
  final String email;
  final int idRol;
  final String token;

  UsuarioModel({
    required this.idUsuario,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.idRol,
    required this.token,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json, String token) {
    return UsuarioModel(
      idUsuario: json['id_usuario'] ?? 0,
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      email: json['email'] ?? '',
      idRol: json['id_rol'] ?? 1,
      token: token,
    );
  }

  // Getters de rol
  bool get esAdmin => idRol == 3;
  bool get esArtista => idRol == 2;
  bool get esUsuario => idRol == 1;
}