import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class PedometerService extends ChangeNotifier {
  StreamSubscription<StepCount>? _subscription;

  int pasos = 0;
  int? _pasosIniciales;
  int? _ultimoConteo;
  int _pasosAntesDeReanudar = 0;

  double longitudPaso = 0.75;

  String mensajeEstado = 'Podómetro detenido';
  String? error;

  double get distanciaMetros => pasos * longitudPaso;

  double get distanciaKilometros => distanciaMetros / 1000;

  bool get activo => _subscription != null;

  // Iniciar un conteo nuevo
  Future<bool> iniciar() async {
    await detener();

    pasos = 0;
    _pasosAntesDeReanudar = 0;
    _pasosIniciales = null;
    _ultimoConteo = null;

    return _iniciarLectura();
  }

  // Reanudar sin perder los pasos anteriores
  Future<bool> reanudar() async {
    if (activo) return true;

    _pasosAntesDeReanudar = pasos;
    _pasosIniciales = null;

    return _iniciarLectura();
  }

  // Activar la lectura del sensor
  Future<bool> _iniciarLectura() async {
    error = null;
    mensajeEstado = 'Solicitando permiso...';
    notifyListeners();

    final permiso =
    await Permission.activityRecognition.request();

    if (!permiso.isGranted) {
      mensajeEstado = 'Permiso de actividad física denegado';
      error = mensajeEstado;
      notifyListeners();
      return false;
    }

    mensajeEstado = 'Esperando datos del sensor...';
    notifyListeners();

    try {
      _subscription = Pedometer.stepCountStream.listen(
            (StepCount evento) {
          _ultimoConteo = evento.steps;

          _pasosIniciales ??= evento.steps;

          pasos = _pasosAntesDeReanudar +
              (evento.steps - _pasosIniciales!);

          if (pasos < 0) pasos = 0;

          mensajeEstado = 'Podómetro funcionando';
          error = null;

          notifyListeners();
        },
        onError: (dynamic e) {
          error = 'Error del sensor: $e';
          mensajeEstado = 'No se reciben datos del podómetro';
          debugPrint(error);
          notifyListeners();
        },
        onDone: () {
          _subscription = null;
          mensajeEstado = 'La lectura del sensor terminó';
          notifyListeners();
        },
      );

      return true;
    } catch (e) {
      error = 'No se pudo iniciar el podómetro: $e';
      mensajeEstado = 'Error al iniciar';
      debugPrint(error);
      notifyListeners();
      return false;
    }
  }

  // Pausar y conservar el conteo
  Future<void> pausar() async {
    await _subscription?.cancel();
    _subscription = null;

    _pasosAntesDeReanudar = pasos;
    mensajeEstado = 'Podómetro en pausa';

    notifyListeners();
  }

  // Detener manualmente
  Future<void> detener() async {
    await _subscription?.cancel();
    _subscription = null;

    mensajeEstado = 'Podómetro detenido';
    notifyListeners();
  }

  // Reiniciar el conteo
  void reiniciar() {
    pasos = 0;
    _pasosAntesDeReanudar = 0;
    _pasosIniciales = _ultimoConteo;

    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}
