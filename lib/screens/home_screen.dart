import 'package:flutter/material.dart';
import 'map_screen.dart';
import 'pedometer_screen.dart';
import 'sensor_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color fondo = Color(0xFF101B19);
  static const Color verde = Color(0xFF18A77A);
  static const Color dorado = Color(0xFFE4BD67);
  static const Color tarjeta = Color(0xFF1B2925);

  Widget tarjetaFuncion({
    required IconData icono,
    required String titulo,
    required String descripcion,
    required VoidCallback accion,
  }) {
    return InkWell(
      onTap: accion,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: tarjeta,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: verde.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icono, color: dorado, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    descripcion,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        backgroundColor: fondo,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'FITTRACK',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Icon(
              Icons.account_circle_outlined,
              size: 28,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(23),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF176B55),
                    Color(0xFF103D32),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TU META COMIENZA HOY',
                    style: TextStyle(
                      color: dorado,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '¡Bienvenido a FitTrack!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Activa tu movimiento, mide tu progreso y supera tus límites.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Icon(Icons.bolt, color: dorado),
                      SizedBox(width: 7),
                      Text(
                        'ES HORA DE ENTRENAR',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'MONITOREO DE ACTIVIDAD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 15),

            tarjetaFuncion(
              icono: Icons.directions_walk,
              titulo: 'Podómetro',
              descripcion: 'Consulta tus pasos y distancia.',
              accion: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PedometerScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            tarjetaFuncion(
              icono: Icons.sensors,
              titulo: 'Sensores de movimiento',
              descripcion: 'Acelerómetro y giroscopio.',
              accion: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SensorScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            tarjetaFuncion(
              icono: Icons.map_outlined,
              titulo: 'Ubicación y recorrido GPS',
              descripcion: 'Visualiza tu ubicación y ruta.',
              accion: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MapScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            tarjetaFuncion(
              icono: Icons.history,
              titulo: 'Historial de entrenamientos',
              descripcion: 'Consulta tus entrenamientos guardados.',
              accion: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            tarjetaFuncion(
              icono: Icons.fingerprint,
              titulo: 'Acceso biométrico',
              descripcion: 'Protección de tu acceso a FitTrack.',
              accion: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'La huella se configura desde el acceso.',
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 25),

            const Center(
              child: Text(
                'FITTRACK  •  TU SALUD EN MOVIMIENTO',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
