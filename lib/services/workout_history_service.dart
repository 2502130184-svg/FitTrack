import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class WorkoutHistoryService {
  static const String _clave = 'fittrack_historial_entrenamientos';

  // Guardar un entrenamiento.
  static Future<bool> guardarEntrenamiento({
    required DateTime fecha,
    required int duracionSegundos,
    required int pasos,
    required double distanciaMetros,
    required List<Map<String, double>> ruta,
  }) async {
    try {
      final preferencias = await SharedPreferences.getInstance();

      final historial = preferencias.getString(_clave);

      final List<dynamic> entrenamientos = historial == null
          ? []
          : jsonDecode(historial) as List<dynamic>;

      final nuevoEntrenamiento = {
        'fecha': fecha.toIso8601String(),
        'duracionSegundos': duracionSegundos,
        'pasos': pasos,
        'distanciaMetros': distanciaMetros,
        'ruta': ruta,
      };

      entrenamientos.add(nuevoEntrenamiento);

      return await preferencias.setString(
        _clave,
        jsonEncode(entrenamientos),
      );
    } catch (e) {
      return false;
    }
  }

  // Consultar todos los entrenamientos guardados.
  static Future<List<Map<String, dynamic>>>
  obtenerEntrenamientos() async {
    try {
      final preferencias = await SharedPreferences.getInstance();

      final historial = preferencias.getString(_clave);

      if (historial == null) {
        return [];
      }

      final List<dynamic> datos = jsonDecode(historial);

      return datos
          .map((elemento) => Map<String, dynamic>.from(elemento))
          .toList()
          .reversed
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Eliminar un entrenamiento por su posición.
  static Future<void> eliminarEntrenamiento(int indice) async {
    final preferencias = await SharedPreferences.getInstance();

    final historial = await obtenerEntrenamientos();

    if (indice < 0 || indice >= historial.length) {
      return;
    }

    // El historial se consulta del más reciente al más antiguo.
    historial.removeAt(indice);

    await preferencias.setString(
      _clave,
      jsonEncode(historial.reversed.toList()),
    );
  }

  // Borrar todo el historial.
  static Future<void> limpiarHistorial() async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.remove(_clave);
  }
}
