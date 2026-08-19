import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'widgets/gradient_header.dart';
import 'screens/login_screen.dart';
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
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> categorias = [
      {
        'titulo': 'Ilustración Digital',
        'descripcion': 'Arte creado con herramientas digitales, tabletas y software especializado.'
      },
      {
        'titulo': 'Pintura Tradicional',
        'descripcion': 'Obras hechas con acrílicos, óleos, acuarelas y técnicas en lienzo.'
      },
      {
        'titulo': 'Escultura y 3D',
        'descripcion': 'Modelado tridimensional físico y digital para proyectos y piezas únicas.'
      },
      {
        'titulo': 'Fotografía Artística',
        'descripcion': 'Capturas con enfoque conceptual, edición visual y narrativa fotográfica.'
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Cabeza de la app
            GradientHeader(
              height: 100,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo
                    Row(
                      children: [
                        Image.asset(
                          'assets/LOGO.png',
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),

                    // Inicio de Sesión / Registro
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryCyan,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16, 
                            vertical: 8,
                          ),
                        ),
                        child: const Text('Sign In / Registro'),
                      )
                  ],
                ),
              ),
            ),

            //Categorias
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Explora Categorías',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Descubre las distintas disciplinas de nuestra comunidad.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Expanded(
                      child: ListView.builder(
                        itemCount: categorias.length,
                        itemBuilder: (context, index) {
                          final cat = categorias[index];
                          return Card(
                            elevation: 1.5,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                color: AppTheme.borderColor,
                                width: 0.5,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.lightCyan.withValues(alpha: 0.2),
                                child: const Icon(
                                  Icons.palette_outlined,
                                  color: AppTheme.primaryCyan,
                                ),
                              ),
                              title: Text(
                                cat['titulo']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  cat['descripcion']!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right,
                                color: AppTheme.primaryCyan,
                              ),
                              onTap: () {
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // pie de pagina
            GradientHeader(
              height: 50,
              child: const Center(
                child: Text(
                  '©2026 ArteNauta',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}