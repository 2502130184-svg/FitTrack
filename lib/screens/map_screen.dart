import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/location_service.dart';
import '../services/pedometer_service.dart';
import '../services/workout_history_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with WidgetsBindingObserver {
  final LocationService _ubicacion = LocationService();
  final PedometerService _podometro = PedometerService();
  final MapController _mapController = MapController();

  final Stopwatch _cronometro = Stopwatch();

  Timer? _temporizador;

  bool _mapaListo = false;
  bool _entrenamientoActivo = false;
  bool _guardando = false;

  // Control de pausa por segundo plano
  bool _reanudarAlVolver = false;
  bool _podometroEstabaActivo = false;
  bool _pausandoAplicacion = false;

  DateTime? _fechaInicio;

  static const Color fondo = Color(0xFF101B19);
  static const Color verde = Color(0xFF18A77A);
  static const Color dorado = Color(0xFFE4BD67);
  static const Color tarjeta = Color(0xFF1B2925);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _ubicacion.addListener(_actualizarMapa);
  }

  // Detectar cuando la aplicación cambia de estado
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      if (_entrenamientoActivo && !_pausandoAplicacion) {
        unawaited(_pausarEntrenamientoEnSegundoPlano());
      }
    }

    if (state == AppLifecycleState.resumed) {
      if (_reanudarAlVolver) {
        unawaited(_reanudarEntrenamiento());
      }
    }
  }

  // Pausar sensores y actualizaciones de pantalla
  Future<void> _pausarEntrenamientoEnSegundoPlano() async {
    if (_pausandoAplicacion || !_entrenamientoActivo) return;

    _pausandoAplicacion = true;
    _reanudarAlVolver = true;

    _podometroEstabaActivo = _podometro.activo;

    _temporizador?.cancel();
    _temporizador = null;

    await _ubicacion.detener();

    if (_podometroEstabaActivo) {
      await _podometro.pausar();
    }

    _pausandoAplicacion = false;
  }

  // Reactivar sensores al regresar a la aplicación
  Future<void> _reanudarEntrenamiento() async {
    if (!_reanudarAlVolver ||
        !_entrenamientoActivo ||
        !mounted) {
      return;
    }

    _reanudarAlVolver = false;

    final gpsCorrecto = await _ubicacion.iniciar();

    if (!mounted || !_entrenamientoActivo) return;

    bool podometroCorrecto = true;

    if (_podometroEstabaActivo) {
      podometroCorrecto = await _podometro.reanudar();
    }

    if (!mounted || !_entrenamientoActivo) return;

    _iniciarTemporizador();

    if (!gpsCorrecto || !podometroCorrecto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El entrenamiento continúa, pero algún sensor no pudo reactivarse.',
          ),
        ),
      );
    }

    setState(() {});
  }

  void _iniciarTemporizador() {
    _temporizador?.cancel();

    _temporizador = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        if (mounted) setState(() {});
      },
    );
  }

  void _actualizarMapa() {
    if (!mounted || !_mapaListo) return;

    final posicion = _ubicacion.posicionActual;

    if (posicion != null) {
      _mapController.move(
        LatLng(posicion.latitude, posicion.longitude),
        17,
      );
    }
  }

  String get _tiempo {
    final duracion = _cronometro.elapsed;

    final horas = duracion.inHours.toString().padLeft(2, '0');
    final minutos =
    (duracion.inMinutes % 60).toString().padLeft(2, '0');
    final segundos =
    (duracion.inSeconds % 60).toString().padLeft(2, '0');

    return '$horas:$minutos:$segundos';
  }

  Future<void> _iniciarEntrenamiento() async {
    if (_entrenamientoActivo || _guardando) return;

    _ubicacion.limpiarRuta();

    final gpsCorrecto = await _ubicacion.iniciar();

    if (!mounted) return;

    if (!gpsCorrecto) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _ubicacion.mensajeError.isEmpty
                ? 'No se pudo iniciar el GPS.'
                : _ubicacion.mensajeError,
          ),
        ),
      );
      return;
    }

    final podometroCorrecto = await _podometro.iniciar();

    if (!mounted) return;

    _podometroEstabaActivo = podometroCorrecto;
    _reanudarAlVolver = false;

    _fechaInicio = DateTime.now();

    _cronometro
      ..reset()
      ..start();

    _iniciarTemporizador();

    setState(() {
      _entrenamientoActivo = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          podometroCorrecto
              ? '¡Entrenamiento iniciado!'
              : 'GPS iniciado. El podómetro no pudo activarse.',
        ),
      ),
    );
  }

  Future<void> _detenerEntrenamiento() async {
    if (!_entrenamientoActivo || _guardando) return;

    setState(() {
      _guardando = true;
    });

    _reanudarAlVolver = false;
    _podometroEstabaActivo = false;

    _cronometro.stop();
    _temporizador?.cancel();
    _temporizador = null;

    final duracion = _cronometro.elapsed.inSeconds;

    await _ubicacion.detener();
    await _podometro.detener();

    final puntosRuta = _ubicacion.ruta.map((punto) {
      return <String, double>{
        'latitud': punto.latitude,
        'longitud': punto.longitude,
      };
    }).toList();

    final guardado =
    await WorkoutHistoryService.guardarEntrenamiento(
      fecha: _fechaInicio ?? DateTime.now(),
      duracionSegundos: duracion,
      pasos: _podometro.pasos,
      distanciaMetros: _podometro.distanciaMetros,
      ruta: puntosRuta,
    );

    if (!mounted) return;

    setState(() {
      _entrenamientoActivo = false;
      _guardando = false;
      _fechaInicio = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          guardado
              ? '¡Entrenamiento guardado correctamente!'
              : 'No se pudo guardar el entrenamiento.',
        ),
      ),
    );
  }

  void _centrarUbicacion() {
    final posicion = _ubicacion.posicionActual;

    if (posicion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero inicia el GPS.'),
        ),
      );
      return;
    }

    _mapController.move(
      LatLng(posicion.latitude, posicion.longitude),
      17,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _temporizador?.cancel();
    _cronometro.stop();

    _ubicacion.removeListener(_actualizarMapa);
    _ubicacion.dispose();
    _podometro.dispose();

    super.dispose();
  }

  Widget _dato(String titulo, String valor, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: tarjeta,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icono, color: dorado, size: 24),
          const SizedBox(height: 8),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        title: const Text('Entrenamiento GPS'),
        backgroundColor: fondo,
        foregroundColor: Colors.white,
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _ubicacion,
          _podometro,
        ]),
        builder: (context, child) {
          final posicion = _ubicacion.posicionActual;

          final puntosRuta = _ubicacion.ruta
              .map(
                (p) => LatLng(
              p.latitude,
              p.longitude,
            ),
          )
              .toList();

          return Column(
            children: [
              Expanded(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(
                      19.4326,
                      -99.1332,
                    ),
                    initialZoom: 5,
                    onMapReady: () {
                      _mapaListo = true;
                      _actualizarMapa();
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                      'com.example.app_deportiva',
                    ),
                    if (puntosRuta.length > 1)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: puntosRuta,
                            strokeWidth: 5,
                            color: verde,
                          ),
                        ],
                      ),
                    if (posicion != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              posicion.latitude,
                              posicion.longitude,
                            ),
                            width: 50,
                            height: 50,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 45,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: fondo,
                  border: Border(
                    top: BorderSide(color: Colors.white12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MI ENTRENAMIENTO',
                      style: TextStyle(
                        color: dorado,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _dato(
                            'Tiempo',
                            _tiempo,
                            Icons.timer_outlined,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _dato(
                            'Pasos',
                            '${_podometro.pasos}',
                            Icons.directions_walk,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _dato(
                            'Distancia',
                            '${_podometro.distanciaMetros.toStringAsFixed(0)} m',
                            Icons.straighten,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      posicion == null
                          ? 'Esperando ubicación GPS...'
                          : 'Latitud: ${posicion.latitude.toStringAsFixed(6)}\n'
                          'Longitud: ${posicion.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Puntos GPS registrados: ${_ubicacion.ruta.length}',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _guardando
                                ? null
                                : _entrenamientoActivo
                                ? _detenerEntrenamiento
                                : _iniciarEntrenamiento,
                            icon: Icon(
                              _entrenamientoActivo
                                  ? Icons.stop
                                  : Icons.play_arrow,
                            ),
                            label: Text(
                              _guardando
                                  ? 'Guardando...'
                                  : _entrenamientoActivo
                                  ? 'Finalizar y guardar'
                                  : 'Iniciar entrenamiento',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _entrenamientoActivo
                                  ? Colors.red.shade700
                                  : verde,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _centrarUbicacion,
                          icon: const Icon(
                            Icons.my_location,
                            color: dorado,
                          ),
                          tooltip: 'Centrar ubicación',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        '© OpenStreetMap contributors',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
