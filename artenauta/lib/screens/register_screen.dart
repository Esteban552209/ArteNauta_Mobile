import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/gradient_header.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _claveController = TextEditingController();
  final _confirmarClaveController = TextEditingController();

  final _authService = AuthService();

  bool _isLoading = false;
  bool _mostrarClave = false;
  bool _mostrarConfirmacion = false;

  Future<void> _handleRegister() async {

    final nombre = _nombreController.text.trim();
    final apellido = _apellidoController.text.trim();
    final telefono = _telefonoController.text.trim();
    final email = _emailController.text.trim();
    final clave = _claveController.text.trim();
    final confirmarClave =
        _confirmarClaveController.text.trim();

    // VALIDACIONES

    if (nombre.isEmpty ||
        apellido.isEmpty ||
        telefono.isEmpty ||
        email.isEmpty ||
        clave.isEmpty ||
        confirmarClave.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor completa todos los campos',
          ),
        ),
      );

      return;
    }

    if (!email.contains('@')) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ingresa un correo electrónico válido',
          ),
        ),
      );

      return;
    }

    if (clave.length < 6) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La contraseña debe tener mínimo 6 caracteres',
          ),
        ),
      );

      return;
    }

    if (clave != confirmarClave) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Las contraseñas no coinciden',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {

      await _authService.registrarUsuario(
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,
        email: email,
        clave: clave,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registro exitoso. Ahora puedes iniciar sesión.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll(
              'Exception: ',
              '',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {

    _nombreController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _claveController.dispose();
    _confirmarClaveController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [

            // =========================
            // HEADER
            // =========================

            const GradientHeader(
              height: 120,
              child: Center(
                child: Text(
                  'ARTENAUTA',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),

            // =========================
            // FORMULARIO
            // =========================

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),

                child: Card(
                  elevation: 8,
                  shadowColor: Colors.black26,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(22),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,

                      children: [

                        const Text(
                          'Registrarme',
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            fontSize: 25,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                AppTheme.primaryCyan,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Empieza a formar parte de la comunidad artística',
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color:
                                AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 25),

                        // NOMBRE

                        _buildLabel(
                          'Nombre',
                        ),

                        const SizedBox(height: 8),

                        TextField(
                          controller:
                              _nombreController,

                          decoration:
                              _inputDecoration(
                            'Nombre',
                            Icons.person_outline,
                          ),
                        ),

                        const SizedBox(height: 17),
                        
                         // Apellido

                        _buildLabel(
                          'Apellido',
                        ),

                        const SizedBox(height: 8),

                        TextField(
                          controller:
                              _apellidoController,

                          decoration:
                              _inputDecoration(
                            'Apellido',
                            Icons.person_outline,
                          ),
                        ),

                        const SizedBox(height: 17),

                        // TELEFONO

                        _buildLabel(
                          'Teléfono',
                        ),

                        const SizedBox(height: 8),

                        TextField(
                          controller:
                              _telefonoController,

                          keyboardType:
                              TextInputType.phone,

                          decoration:
                              _inputDecoration(
                            'Teléfono',
                            Icons.phone_outlined,
                          ),
                        ),

                        const SizedBox(height: 17),

                        // EMAIL

                        _buildLabel(
                          'Email',
                        ),

                        const SizedBox(height: 8),

                        TextField(
                          controller:
                              _emailController,

                          keyboardType:
                              TextInputType.emailAddress,

                          decoration:
                              _inputDecoration(
                            'Correo Electrónico',
                            Icons.email_outlined,
                          ),
                        ),

                        const SizedBox(height: 17),

                        // CONTRASEÑA

                        _buildLabel(
                          'Contraseña',
                        ),

                        const SizedBox(height: 8),

                        TextField(
                          controller:
                              _claveController,

                          obscureText:
                              !_mostrarClave,

                          decoration:
                              _inputDecoration(
                            'Contraseña',
                            Icons.lock_outline,
                          ).copyWith(
                            suffixIcon:
                                IconButton(
                              icon: Icon(
                                _mostrarClave
                                    ? Icons
                                        .visibility_off
                                    : Icons
                                        .visibility,
                              ),

                              onPressed: () {
                                setState(() {
                                  _mostrarClave =
                                      !_mostrarClave;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 17),

                        // CONFIRMAR CONTRASEÑA

                        _buildLabel(
                          'Confirmar Contraseña',
                        ),

                        const SizedBox(height: 8),

                        TextField(
                          controller:
                              _confirmarClaveController,

                          obscureText:
                              !_mostrarConfirmacion,

                          decoration:
                              _inputDecoration(
                            'Confirmar Contraseña',
                            Icons.lock_reset_outlined,
                          ).copyWith(
                            suffixIcon:
                                IconButton(
                              icon: Icon(
                                _mostrarConfirmacion
                                    ? Icons
                                        .visibility_off
                                    : Icons
                                        .visibility,
                              ),

                              onPressed: () {
                                setState(() {
                                  _mostrarConfirmacion =
                                      !_mostrarConfirmacion;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // BOTÓN

                        SizedBox(
                          height: 52,

                          child: ElevatedButton(
                            onPressed:
                                _isLoading
                                    ? null
                                    : _handleRegister,

                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppTheme.primaryCyan,

                              foregroundColor:
                                  Colors.white,

                              elevation: 2,

                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  10,
                                ),
                              ),
                            ),

                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,

                                    child:
                                        CircularProgressIndicator(
                                      color:
                                          Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Registrarme',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // IR AL LOGIN

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [

                            const Text(
                              '¿Ya tienes cuenta? ',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),

                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const LoginScreen(),
                                  ),
                                );
                              },

                              child: const Text(
                                'Iniciar Sesión',
                                style: TextStyle(
                                  color:
                                      AppTheme.primaryCyan,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // FOOTER

            const GradientHeader(
              height: 70,

              child: Center(
                child: Text(
                  '©2026\nArteNauta',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppTheme.primaryCyan,
          width: 2,
        ),
      ),
    );
  }
}