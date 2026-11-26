import 'package:flutter/material.dart';
import '../services/pedometer_service.dart';

class PedometerScreen extends StatefulWidget {
  const PedometerScreen({super.key});

  @override
  State<PedometerScreen> createState() => _PedometerScreenState();
}

class _PedometerScreenState extends State<PedometerScreen>
    with WidgetsBindingObserver {
  final PedometerService _servicio = PedometerService();

  bool cargando = false;
  bool _reanudarAlVolver = false;

  static const Color fondo = Color(0xFF101B19);
  static const Color verde = Color(0xFF18A77A);
  static const Color dorado = Color(0xFFE4BD67);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  // Detectar cuando la aplicación pasa a segundo plano
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _reanudarAlVolver = _servicio.activo;

      if (_servicio.activo) {
        _servicio.pausar();
      }
    }

    if (state == AppLifecycleState.resumed) {
      if (_reanudarAlVolver) {
        _reanudarAlVolver = false;
        _servicio.reanudar();
      }
    }
  }

  Future<void> iniciarConteo() async {
    setState(() => cargando = true);

    final resultado = await _servicio.iniciar();

    if (!mounted) return;

    setState(() {
      cargando = false;
      _reanudarAlVolver = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          resultado
              ? '¡Podómetro activado!'
              : 'No se pudo activar. Revisa los permisos de actividad física.',
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _servicio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        title: const Text('Podómetro'),
        backgroundColor: fondo,
        foregroundColor: Colors.white,
      ),
      body: AnimatedBuilder(
        animation: _servicio,
        builder: (context, child) {
          return Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                const SizedBox(height: 25),
                const Text(
                  'TU ACTIVIDAD',
                  style: TextStyle(
                    color: dorado,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1B2925),
                    border: Border.all(color: verde, width: 5),
                    boxShadow: [
                      BoxShadow(
                        color: verde.withValues(alpha: 0.15),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.directions_walk,
                        color: dorado,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${_servicio.pasos}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 43,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'PASOS',
                        style: TextStyle(
                          color: Colors.white60,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),
                Row(
                  children: [
                    Expanded(
                      child: dato(
                        Icons.straighten,
                        'Distancia',
                        '${_servicio.distanciaMetros.toStringAsFixed(1)} m',
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: dato(
                        Icons.route,
                        'Kilómetros',
                        '${_servicio.distanciaKilometros.toStringAsFixed(3)} km',
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 53,
                  child: ElevatedButton.icon(
                    onPressed: cargando || _servicio.activo
                        ? null
                        : iniciarConteo,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(
                      cargando ? 'ACTIVANDO...' : 'INICIAR CONTEO',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: verde,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 53,
                  child: OutlinedButton.icon(
                    onPressed: _servicio.activo
                        ? () {
                      _reanudarAlVolver = false;
                      _servicio.detener();
                    }
                        : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('DETENER'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: dorado,
                      side: const BorderSide(color: dorado),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    _servicio.reiniciar();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('REINICIAR CONTEO'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
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

  Widget dato(IconData icono, String titulo, String valor) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2925),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          Icon(icono, color: dorado, size: 28),
          const SizedBox(height: 10),
          Text(
            titulo,
            style: const TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 5),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
