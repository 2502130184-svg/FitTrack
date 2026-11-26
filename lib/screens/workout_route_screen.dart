import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class WorkoutRouteScreen extends StatelessWidget {
  final List<dynamic> ruta;

  const WorkoutRouteScreen({
    super.key,
    required this.ruta,
  });

  static const Color fondo = Color(0xFF101B19);
  static const Color verde = Color(0xFF18A77A);
  static const Color dorado = Color(0xFFE4BD67);

  @override
  Widget build(BuildContext context) {
    final List<LatLng> puntos = ruta.map((elemento) {
      final coordenadas = Map<String, dynamic>.from(elemento);

      return LatLng(
        (coordenadas['latitud'] as num).toDouble(),
        (coordenadas['longitud'] as num).toDouble(),
      );
    }).toList();

    if (puntos.isEmpty) {
      return Scaffold(
        backgroundColor: fondo,
        appBar: AppBar(
          title: const Text('Mi recorrido'),
          backgroundColor: fondo,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(25),
            child: Text(
              'Este entrenamiento no tiene puntos GPS registrados.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        title: const Text('Mi recorrido'),
        backgroundColor: fondo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: puntos.first,
                initialZoom: 16,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName:
                  'com.example.app_deportiva',
                ),

                if (puntos.length > 1)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: puntos,
                        strokeWidth: 5,
                        color: verde,
                      ),
                    ],
                  ),

                MarkerLayer(
                  markers: [
                    Marker(
                      point: puntos.first,
                      width: 45,
                      height: 45,
                      child: const Icon(
                        Icons.flag_circle,
                        color: Colors.green,
                        size: 40,
                      ),
                    ),
                    if (puntos.length > 1)
                      Marker(
                        point: puntos.last,
                        width: 45,
                        height: 45,
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
            padding: const EdgeInsets.all(18),
            color: fondo,
            child: Column(
              children: [
                const Text(
                  'RECORRIDO REGISTRADO',
                  style: TextStyle(
                    color: dorado,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Puntos GPS: ${puntos.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Inicio en verde · Final en rojo',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '© OpenStreetMap contributors',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
