import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService extends ChangeNotifier {
  StreamSubscription<Position>? _ubicacionSubscription;

  Position? posicionActual;
  List<Position> ruta = [];

  bool activo = false;
  String mensajeError = '';

  Future<bool> iniciar() async {
    mensajeError = '';

    // Comprobar que el GPS esté encendido.
    final servicioActivo =
    await Geolocator.isLocationServiceEnabled();

    if (!servicioActivo) {
      mensajeError = 'Activa el GPS de tu dispositivo.';
      notifyListeners();
      return false;
    }

    // Comprobar permisos de ubicación.
    LocationPermission permiso =
    await Geolocator.checkPermission();

    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    if (permiso == LocationPermission.denied) {
      mensajeError = 'No se concedió el permiso de ubicación.';
      notifyListeners();
      return false;
    }

    if (permiso == LocationPermission.deniedForever) {
      mensajeError =
      'El permiso está bloqueado. Actívalo en los ajustes.';
      notifyListeners();
      return false;
    }

    // Evitar crear varias suscripciones.
    await detener();

    try {
      activo = true;
      notifyListeners();

      _ubicacionSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5,
            ),
          ).listen(
                (Position posicion) {
              posicionActual = posicion;
              ruta.add(posicion);
              notifyListeners();
            },
            onError: (error) {
              mensajeError = 'Error al obtener ubicación: $error';
              activo = false;
              notifyListeners();
            },
          );

      return true;
    } catch (e) {
      activo = false;
      mensajeError = 'No se pudo iniciar el GPS: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> detener() async {
    await _ubicacionSubscription?.cancel();
    _ubicacionSubscription = null;

    activo = false;
    notifyListeners();
  }

  void limpiarRuta() {
    ruta.clear();
    posicionActual = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _ubicacionSubscription?.cancel();
    super.dispose();
  }
}
