import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorService extends ChangeNotifier {
  StreamSubscription<AccelerometerEvent>? _acelerometroSubscription;
  StreamSubscription<GyroscopeEvent>? _giroscopioSubscription;

  // Valores del acelerómetro
  double x = 0;
  double y = 0;
  double z = 0;

  // Valores del giroscopio (rad/s)
  double giroX = 0;
  double giroY = 0;
  double giroZ = 0;

  // Orientación estimada en grados
  double orientacionX = 0;
  double orientacionY = 0;
  double orientacionZ = 0;

  DateTime? _ultimaLecturaGiro;

  // Clasificación del movimiento
  String intensidad = 'Descanso';

  bool activo = false;

  // Magnitud de la aceleración
  double get magnitudAceleracion {
    return math.sqrt(x * x + y * y + z * z);
  }

  // Magnitud de la velocidad angular
  double get magnitudGiro {
    return math.sqrt(
      giroX * giroX +
          giroY * giroY +
          giroZ * giroZ,
    );
  }

  // Activar sensores
  Future<void> iniciar() async {
    await detener();

    orientacionX = 0;
    orientacionY = 0;
    orientacionZ = 0;
    _ultimaLecturaGiro = null;

    activo = true;

    _acelerometroSubscription =
        accelerometerEventStream(
          samplingPeriod: SensorInterval.normalInterval,
        ).listen(
              (AccelerometerEvent evento) {
            x = evento.x;
            y = evento.y;
            z = evento.z;

            _clasificarMovimiento();

            notifyListeners();
          },
          onError: (error) {
            debugPrint('Error del acelerómetro: $error');
          },
        );

    _giroscopioSubscription =
        gyroscopeEventStream(
          samplingPeriod: SensorInterval.normalInterval,
        ).listen(
              (GyroscopeEvent evento) {
            giroX = evento.x;
            giroY = evento.y;
            giroZ = evento.z;

            // Calcular el tiempo transcurrido
            final ahora = DateTime.now();

            if (_ultimaLecturaGiro != null) {
              final segundos = ahora
                  .difference(_ultimaLecturaGiro!)
                  .inMicroseconds /
                  1000000.0;

              // Convertir velocidad angular a grados
              const factorGrados = 180 / math.pi;

              orientacionX += giroX * segundos * factorGrados;
              orientacionY += giroY * segundos * factorGrados;
              orientacionZ += giroZ * segundos * factorGrados;
            }

            _ultimaLecturaGiro = ahora;

            notifyListeners();
          },
          onError: (error) {
            debugPrint('Error del giroscopio: $error');
          },
        );

    notifyListeners();
  }

  // Clasificar la intensidad del movimiento
  void _clasificarMovimiento() {
    final aceleracion = (magnitudAceleracion - 9.81).abs();

    if (aceleracion < 0.8) {
      intensidad = 'Descanso';
    } else if (aceleracion < 2.5) {
      intensidad = 'Caminata';
    } else {
      intensidad = 'Trote';
    }
  }

  // Detener y liberar sensores
  Future<void> detener() async {
    await _acelerometroSubscription?.cancel();
    await _giroscopioSubscription?.cancel();

    _acelerometroSubscription = null;
    _giroscopioSubscription = null;

    _ultimaLecturaGiro = null;
    activo = false;

    notifyListeners();
  }

  @override
  void dispose() {
    detener();
    super.dispose();
  }
}
