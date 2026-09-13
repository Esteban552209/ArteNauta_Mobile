class ApiConfig {
  // Usar la IP del PC para probar en dispositivo físico, o 10.0.2.2 para el emulador de Android
  static const String baseUrl = 'http://192.168.1.6:3000/mobile'; 
  
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}