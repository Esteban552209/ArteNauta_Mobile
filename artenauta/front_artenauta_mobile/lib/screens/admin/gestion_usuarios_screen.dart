import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../services/session_service.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/gradient_header.dart';

class GestionUsuariosScreen extends StatefulWidget {
  const GestionUsuariosScreen({super.key});

  @override
  State<GestionUsuariosScreen> createState() => _GestionUsuariosScreenState();
}

class _GestionUsuariosScreenState extends State<GestionUsuariosScreen> {
  List<dynamic> _usuarios = [];
  bool _isLoading = true;

  final _buscarController = TextEditingController();
  String? _filtroEstado;
  String? _filtroRol;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    setState(() => _isLoading = true);
    try {
      final String? token = await SessionService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final String baseUrl = dotenv.env['SUPABASE_URL']!;

      Uri url = Uri.parse('$baseUrl/functions/v1/gestion_usuarios');
      Map<String, String> queryParams = {};
      
      if (_buscarController.text.isNotEmpty) queryParams['buscar'] = _buscarController.text;
      if (_filtroEstado != null) queryParams['estado'] = _filtroEstado!;
      if (_filtroRol != null) queryParams['rol'] = _filtroRol!;

      if (queryParams.isNotEmpty) {
        url = url.replace(queryParameters: queryParams);
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) throw Exception(data['error']);

      setState(() => _usuarios = data);
    } catch (e) {
      debugPrint("Error GET Usuarios: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _mostrarModalEdicion(Map<String, dynamic> usuario) {
    final nombreCtrl = TextEditingController(text: usuario['nombre']);
    final apellidoCtrl = TextEditingController(text: usuario['apellido']);
    bool estadoCuenta = usuario['estado_cuenta'] ?? true;
    int idRol = usuario['id_rol'];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              title: const Text('Editar Usuario', style: TextStyle(color: AppTheme.primaryCyan)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: apellidoCtrl,
                      decoration: const InputDecoration(labelText: 'Apellido'),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<int>(
                      value: idRol,
                      decoration: const InputDecoration(labelText: 'Rol'),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Usuario Final')),
                        DropdownMenuItem(value: 2, child: Text('Artista')),
                        DropdownMenuItem(value: 3, child: Text('Administrador')),
                      ],
                      onChanged: (val) => setStateModal(() => idRol = val!),
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      title: const Text('Cuenta Activa'),
                      value: estadoCuenta,
                      activeColor: AppTheme.primaryCyan,
                      onChanged: (val) => setStateModal(() => estadoCuenta = val),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryCyan),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _actualizarUsuario(
                      idUsuario: usuario['id_usuario'],
                      nombre: nombreCtrl.text,
                      apellido: apellidoCtrl.text,
                      idRol: idRol,
                      estado: estadoCuenta,
                    );
                  },
                  child: const Text('Guardar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _actualizarUsuario({
    required int idUsuario,
    required String nombre,
    required String apellido,
    required int idRol,
    required bool estado,
  }) async {
    try {
      final String? token = await SessionService.getToken();
      final String baseUrl = dotenv.env['SUPABASE_URL']!;
      final url = Uri.parse('$baseUrl/functions/v1/gestion_usuarios');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'id_usuario': idUsuario,
          'nombre': nombre,
          'apellido': apellido,
          'id_rol': idRol,
          'estado_cuenta': estado,
        }),
      );

      if (response.statusCode == 200) {
        _cargarUsuarios();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario actualizado correctamente'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint("Error PATCH: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          GradientHeader(
            height: 110,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Gestión de Usuarios',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _buscarController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o email...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onSubmitted: (_) => _cargarUsuarios(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: AppTheme.primaryCyan),
                  onPressed: _cargarUsuarios,
                )
              ],
            ),
          ),

          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _cargarUsuarios,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _usuarios.length,
                    itemBuilder: (context, index) {
                      final u = _usuarios[index];
                      final bool activo = u['estado_cuenta'] ?? false;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryCyan.withOpacity(0.2),
                            child: Text(
                              u['nombre'].toString().substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text('${u['nombre']} ${u['apellido']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(u['email'], style: const TextStyle(fontSize: 12)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      u['roles'] != null ? u['roles']['nombre_rol'] : 'Rol ${u['id_rol']}', 
                                      style: const TextStyle(fontSize: 11)
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    activo ? Icons.check_circle : Icons.cancel, 
                                    color: activo ? Colors.green : Colors.red, 
                                    size: 16
                                  ),
                                ],
                              )
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.grey),
                            onPressed: () => _mostrarModalEdicion(u),
                          ),
                        ),
                      );
                    },
                  ),
                ),
          ),
        ],
      ),
    );
  }
}