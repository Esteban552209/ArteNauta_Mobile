import 'package:flutter/material.dart';
import '../../services/session_service.dart';
import '../../services/reacciones_service.dart';

class LikeButton extends StatefulWidget {
  final int? idPublicacion;

  const LikeButton({
    super.key,
    required this.idPublicacion,
  });

  @override
  State<LikeButton> createState() =>
      _LikeButtonState();
}

class _LikeButtonState
    extends State<LikeButton> {

  final ReaccionesService _reaccionesService =
      ReaccionesService();

  int? _idUsuario;

  bool _dioLike = false;

  int _cantidadLikes = 0;

  bool _cargando = true;

  bool _procesando = false;

  @override
  void initState() {
    super.initState();

    _cargarInformacion();
  }

  Future<void> _cargarInformacion() async {
    if (widget.idPublicacion == null) {
      return;
    }

    try {
      final usuario =
          await SessionService.getUsuario();

      final idUsuario =
          int.tryParse(
            usuario?['id_usuario']?.toString() ?? '',
          );

      if (idUsuario == null) {
        return;
      }

      final dioLike =
          await _reaccionesService.usuarioDioMeGusta(
        idPublicacion:
            widget.idPublicacion!,
        idUsuario:
            idUsuario,
      );

      final cantidad =
          await _reaccionesService
              .obtenerCantidadLikes(
        idPublicacion:
            widget.idPublicacion!,
      );

      if (!mounted) return;

      setState(() {
        _idUsuario = idUsuario;
        _dioLike = dioLike;
        _cantidadLikes = cantidad;
        _cargando = false;
      });
    } catch (e) {
      debugPrint(
        'Error cargando información del like: $e',
      );

      if (!mounted) return;

      setState(() {
        _cargando = false;
      });
    }
  }

  Future<void> _alternarLike() async {
    if (_idUsuario == null ||
        widget.idPublicacion == null ||
        _procesando) {
      return;
    }

    setState(() {
      _procesando = true;
    });

    try {
      if (_dioLike) {
 
        await _reaccionesService.quitarMeGusta(
          idPublicacion:
              widget.idPublicacion!,
          idUsuario:
              _idUsuario!,
        );

        if (!mounted) return;

        setState(() {
          _dioLike = false;

          if (_cantidadLikes > 0) {
            _cantidadLikes--;
          }
        });
      } else {

        await _reaccionesService.darMeGusta(
          idPublicacion:
              widget.idPublicacion!,
          idUsuario:
              _idUsuario!,
        );

        if (!mounted) return;

        setState(() {
          _dioLike = true;
          _cantidadLikes++;
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo actualizar el Me Gusta: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _procesando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const SizedBox(
        height: 40,
        width: 100,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.redAccent,
            ),
          ),
        ),
      );
    }

    return TextButton.icon(
      onPressed:
          _procesando
              ? null
              : _alternarLike,

      icon: _procesando
          ? const SizedBox(
              width: 18,
              height: 18,
              child:
                  CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.redAccent,
              ),
            )
          : Icon(
              _dioLike
                  ? Icons.favorite
                  : Icons.favorite_border,

              color:
                  _dioLike
                      ? Colors.redAccent
                      : Colors.grey,
            ),

      label: Text(
        _dioLike
            ? 'Te gusta ($_cantidadLikes)'
            : 'Me gusta ($_cantidadLikes)',

        style: TextStyle(
          color:
              _dioLike
                  ? Colors.redAccent
                  : Colors.black87,

          fontWeight:
              _dioLike
                  ? FontWeight.bold
                  : FontWeight.normal,
        ),
      ),
    );
  }
}