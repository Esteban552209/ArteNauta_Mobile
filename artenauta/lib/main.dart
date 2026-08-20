import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/session_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://oqvuiosndsxjqelefokc.supabase.co',
    anonKey: 'sb_publishable_3Vc1WhpZiW1x_R8VP1fOsw_C_uSsSIp',
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

// Verifica si hay sesión activa al abrir la app
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
    final hay = await SessionService.haySesion();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => hay ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}