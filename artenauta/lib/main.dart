import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin/admin_users_screen.dart';
import 'screens/artista_screen.dart'; 
import 'screens/usuario_screen.dart'; 
import 'services/session_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
  );

  runApp(const ArtenautaApp());
}

class ArtenautaApp extends StatelessWidget {
  const ArtenautaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArteNauta',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashRouter(),
    );
  }
}

class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  @override
  void initState() {
    super.initState();
    _verificar();
  }

  Future<void> _verificar() async {
    await SessionService.cerrarSesion(); 

    final hay = await SessionService.haySesion();
    if (!mounted) return;

    if (hay) {
      final rol = await SessionService.getRol();
      Widget pantallaDestino;

      if (rol == 3) { 
        pantallaDestino = const AdminUsersScreen();
      } else if (rol == 2) {
        pantallaDestino = const TestArtistaScreen(); 
      } else if (rol == 1) {
        pantallaDestino = const UsuarioScreen(); 
      } else {
        pantallaDestino = const HomeScreen(); 
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => pantallaDestino),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}