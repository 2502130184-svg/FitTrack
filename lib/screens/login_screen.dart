import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/biometric_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final BiometricService _biometria = BiometricService();

  bool _cargando = false;
  bool _disponible = false;
  bool _mostrarPassword = false;

  static const Color fondo = Color(0xFF101B19);
  static const Color verde = Color(0xFF18A77A);
  static const Color dorado = Color(0xFFE4BD67);

  @override
  void initState() {
    super.initState();
    _comprobarBiometria();
  }

  Future<void> _comprobarBiometria() async {
    final resultado = await _biometria.biometriaDisponible();

    if (!mounted) return;

    setState(() {
      _disponible = resultado;
    });
  }

  Future<void> _iniciarSesion() async {
    final correo = _correoController.text.trim();
    final password = _passwordController.text;

    if (correo.isEmpty || password.isEmpty) {
      _mensaje('Completa tu correo y contraseña.');
      return;
    }

    setState(() => _cargando = true);

    final preferencias = await SharedPreferences.getInstance();

    final correoGuardado = preferencias.getString('correo') ?? '';
    final passwordGuardado = preferencias.getString('password') ?? '';

    if (!mounted) return;

    setState(() => _cargando = false);

    if (correo == correoGuardado && password == passwordGuardado) {
      _entrar();
    } else {
      _mensaje('Correo o contraseña incorrectos.');
    }
  }

  Future<void> _iniciarConHuella() async {
    setState(() => _cargando = true);

    final resultado = await _biometria.autenticar();

    if (!mounted) return;

    setState(() => _cargando = false);

    if (resultado) {
      _entrar();
    } else {
      _mensaje(
        'No se pudo validar la huella. Comprueba la configuración biométrica de tu celular.',
      );
    }
  }

  void _entrar() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 26,
              vertical: 25,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 39,
                        backgroundColor: Color(0xFF1D3931),
                        child: Icon(
                          Icons.directions_run_rounded,
                          color: verde,
                          size: 45,
                        ),
                      ),
                      SizedBox(height: 18),
                      Text(
                        'FITTRACK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 31,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'SUPERA TUS PROPIOS LÍMITES',
                        style: TextStyle(
                          color: dorado,
                          fontSize: 10,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                const Text(
                  '¡Qué gusto tenerte aquí!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Inicia sesión y continúa trabajando en tu mejor versión.',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 30),

                _campo(
                  controller: _correoController,
                  etiqueta: 'Correo electrónico',
                  icono: Icons.email_outlined,
                ),

                const SizedBox(height: 17),

                _campo(
                  controller: _passwordController,
                  etiqueta: 'Contraseña',
                  icono: Icons.lock_outline,
                  esPassword: true,
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _iniciarSesion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: verde,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _cargando
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : const Text(
                      'INICIAR SESIÓN',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                const Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'O INGRESA CON',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.white24)),
                  ],
                ),

                const SizedBox(height: 20),

                Center(
                  child: InkWell(
                    onTap: _cargando || !_disponible
                        ? null
                        : _iniciarConHuella,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D3931),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: verde.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.fingerprint,
                            size: 53,
                            color: _disponible ? dorado : Colors.white38,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _disponible
                                ? 'Acceder con huella'
                                : 'Huella no disponible',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      const Text(
                        '¿Todavía no tienes una cuenta? ',
                        style: TextStyle(color: Colors.white60),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Regístrate',
                          style: TextStyle(
                            color: dorado,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String etiqueta,
    required IconData icono,
    bool esPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: esPassword && !_mostrarPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: etiqueta,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icono, color: verde),
        suffixIcon: esPassword
            ? IconButton(
          icon: Icon(
            _mostrarPassword
                ? Icons.visibility_off
                : Icons.visibility,
            color: Colors.white54,
          ),
          onPressed: () {
            setState(() {
              _mostrarPassword = !_mostrarPassword;
            });
          },
        )
            : null,
        filled: true,
        fillColor: const Color(0xFF1A2925),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
