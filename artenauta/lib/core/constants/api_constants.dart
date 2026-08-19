class ApiConstants {
  // URL de tu backend Express
  static const String baseUrl = '192.168.20.1:3000/api';
  
  // Endpoints notificaciones
  static const String notificaciones = '$baseUrl/notificaciones';
  static const String marcarLeidas = '$baseUrl/notificaciones/marcar-leidas';
  static const String solicitudes = '$baseUrl/notificaciones/solicitudes';
  static const String aprobarSolicitud = '$baseUrl/notificaciones/solicitudes';
  static const String rechazarSolicitud = '$baseUrl/notificaciones/solicitudes';
  
  // Endpoints auth
  static const String login = '$baseUrl/auth/login';
}