import 'package:flutter/material.dart';
import '../services/workout_history_service.dart';
import 'workout_route_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const Color fondo = Color(0xFF101B19);
  static const Color verde = Color(0xFF18A77A);
  static const Color dorado = Color(0xFFE4BD67);

  List<Map<String, dynamic>> entrenamientos = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarHistorial();
  }

  Future<void> cargarHistorial() async {
    final datos =
    await WorkoutHistoryService.obtenerEntrenamientos();

    if (!mounted) return;

    setState(() {
      entrenamientos = datos;
      cargando = false;
    });
  }

  String formatoDuracion(int segundos) {
    final horas = segundos ~/ 3600;
    final minutos = (segundos % 3600) ~/ 60;
    final restantes = segundos % 60;

    if (horas > 0) {
      return '${horas}h ${minutos}min';
    }

    return '${minutos}min ${restantes}s';
  }

  String formatoFecha(String fecha) {
    final date = DateTime.parse(fecha).toLocal();

    final dia = date.day.toString().padLeft(2, '0');
    final mes = date.month.toString().padLeft(2, '0');
    final anio = date.year;

    final hora = date.hour.toString().padLeft(2, '0');
    final minuto = date.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$anio · $hora:$minuto';
  }

  Future<void> eliminarEntrenamiento(int indice) async {
    await WorkoutHistoryService.eliminarEntrenamiento(indice);
    await cargarHistorial();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Entrenamiento eliminado'),
      ),
    );
  }

  Future<void> confirmarEliminacion(int indice) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B2925),
        title: const Text(
          'Eliminar entrenamiento',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Seguro que deseas eliminar este registro?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await eliminarEntrenamiento(indice);
    }
  }

  void verRecorrido(List<dynamic> ruta) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutRouteScreen(ruta: ruta),
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
        title: const Text('Historial de entrenamientos'),
      ),
      body: cargando
          ? const Center(
        child: CircularProgressIndicator(color: verde),
      )
          : entrenamientos.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.history,
                size: 85,
                color: dorado,
              ),
              const SizedBox(height: 20),
              const Text(
                'Aún no tienes entrenamientos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Cuando finalices y guardes un entrenamiento, '
                    'aparecerá aquí tu historial.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: cargarHistorial,
                icon: const Icon(Icons.refresh),
                label: const Text('Actualizar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: dorado,
                ),
              ),
            ],
          ),
        ),
      )
          : RefreshIndicator(
        color: verde,
        onRefresh: cargarHistorial,
        child: ListView.builder(
          padding: const EdgeInsets.all(18),
          itemCount: entrenamientos.length,
          itemBuilder: (context, indice) {
            final entrenamiento = entrenamientos[indice];

            final pasos =
                (entrenamiento['pasos'] as num?)?.toInt() ?? 0;

            final metros =
                (entrenamiento['distanciaMetros'] as num?)
                    ?.toDouble() ??
                    0.0;

            final duracion =
                (entrenamiento['duracionSegundos'] as num?)
                    ?.toInt() ??
                    0;

            final ruta =
                entrenamiento['ruta'] as List<dynamic>? ?? [];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2925),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: verde.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: dorado,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          formatoFecha(
                            entrenamiento['fecha'] as String,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            confirmarEliminacion(indice),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: dato(
                          Icons.directions_walk,
                          'Pasos',
                          '$pasos',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: dato(
                          Icons.timer_outlined,
                          'Duración',
                          formatoDuracion(duracion),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: dato(
                          Icons.route,
                          'Distancia',
                          '${metros.toStringAsFixed(1)} m',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: dato(
                          Icons.location_on_outlined,
                          'Puntos GPS',
                          '${ruta.length}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: ruta.isEmpty
                          ? null
                          : () => verRecorrido(ruta),
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('VER RECORRIDO'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: dorado,
                        side: const BorderSide(color: dorado),
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget dato(IconData icono, String titulo, String valor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          Icon(icono, color: dorado, size: 25),
          const SizedBox(height: 7),
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            valor,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
