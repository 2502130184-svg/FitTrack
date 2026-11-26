
import 'package:flutter/material.dart';
import '../services/sensor_service.dart';

class SensorScreen extends StatefulWidget {
  const SensorScreen({super.key});

  @override
  State<SensorScreen> createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen>
    with WidgetsBindingObserver {
  final SensorService _servicio = SensorService();

  static const Color fondo = Color(0xFF101B19);
  static const Color verde = Color(0xFF18A77A);
  static const Color dorado = Color(0xFFE4BD67);

  bool _reanudarAlVolver = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _reanudarAlVolver = _servicio.activo;

      if (_servicio.activo) {
        _servicio.detener();
      }
    }

    if (state == AppLifecycleState.resumed) {
      if (_reanudarAlVolver) {
        _reanudarAlVolver = false;
        _servicio.iniciar();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _servicio.dispose();
    super.dispose();
  }

  Widget tarjetaSensor(
      String titulo,
      IconData icono,
      double x,
      double y,
      double z,
      String unidad,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2925),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: dorado, size: 27),
              const SizedBox(width: 10),
              Text(
                titulo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          filaEje('Eje X', x, unidad),
          filaEje('Eje Y', y, unidad),
          filaEje('Eje Z', z, unidad),
        ],
      ),
    );
  }

  Widget filaEje(String eje, double valor, String unidad) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            eje,
            style: const TextStyle(color: Colors.white60),
          ),
          Text(
            '${valor.toStringAsFixed(2)} $unidad',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
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
        title: const Text('Sensores de movimiento'),
        backgroundColor: fondo,
        foregroundColor: Colors.white,
      ),
      body: AnimatedBuilder(
        animation: _servicio,
        builder: (context, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'MONITOREO EN TIEMPO REAL',
                  style: TextStyle(
                    color: dorado,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                tarjetaSensor(
                  'Acelerómetro',
                  Icons.speed,
                  _servicio.x,
                  _servicio.y,
                  _servicio.z,
                  'm/s²',
                ),

                const SizedBox(height: 15),

                tarjetaSensor(
                  'Giroscopio',
                  Icons.screen_rotation,
                  _servicio.giroX,
                  _servicio.giroY,
                  _servicio.giroZ,
                  'rad/s',
                ),

                const SizedBox(height: 15),

                // Nueva tarjeta de orientación
                tarjetaSensor(
                  'Orientación del dispositivo',
                  Icons.threed_rotation,
                  _servicio.orientacionX,
                  _servicio.orientacionY,
                  _servicio.orientacionZ,
                  '°',
                ),

                const SizedBox(height: 8),

                const Text(
                  'Valores estimados de inclinación y giro del teléfono.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 15),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2925),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.directions_run,
                        color: dorado,
                        size: 40,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'INTENSIDAD DEL MOVIMIENTO',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _servicio.intensidad,
                        style: const TextStyle(
                          color: verde,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aceleración: ${_servicio.magnitudAceleracion.toStringAsFixed(2)} m/s²',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _servicio.activo
                        ? () {
                      _reanudarAlVolver = false;
                      _servicio.detener();
                    }
                        : () {
                      _servicio.iniciar();
                    },
                    icon: Icon(
                      _servicio.activo
                          ? Icons.stop
                          : Icons.play_arrow,
                    ),
                    label: Text(
                      _servicio.activo
                          ? 'DETENER SENSORES'
                          : 'INICIAR SENSORES',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: verde,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
