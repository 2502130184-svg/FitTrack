import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _password = TextEditingController();
  final _confirmar = TextEditingController();

  bool _cargando = false;
  bool _mostrarPassword = false;

  static const Color fondo = Color(0xFF101B19);
  static const Color verde = Color(0xFF18A77A);
  static const Color dorado = Color(0xFFE4BD67);

  Future<void> _registrar() async {
    final nombre = _nombre.text.trim();
    final correo = _correo.text.trim();
    final password = _password.text;
    final confirmar = _confirmar.text;

    if (nombre.isEmpty || correo.isEmpty ||
        password.isEmpty || confirmar.isEmpty) {
      _mensaje('Completa todos los campos.');
      return;
    }

    if (!correo.contains('@') || !correo.contains('.')) {
      _mensaje('Escribe un correo electrónico válido.');
      return;
    }

    if (password.length < 6) {
      _mensaje('La contraseña debe tener al menos 6 caracteres.');
      return;
    }

    if (password != confirmar) {
      _mensaje('Las contraseñas no coinciden.');
      return;
    }

    setState(() => _cargando = true);

    final preferencias = await SharedPreferences.getInstance();

    await preferencias.setString('nombre', nombre);
    await preferencias.setString('correo', correo);
    await preferencias.setString('password', password);

    if (!mounted) return;

    setState(() => _cargando = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Cuenta registrada correctamente!'),
      ),
    );

    Navigator.pop(context);
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _password.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        backgroundColor: fondo,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Crear cuenta'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Icon(
                  Icons.person_add_alt_1,
                  color: dorado,
                  size: 65,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Únete a FitTrack',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Crea tu cuenta y comienza a registrar tu progreso.',
                style: TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 30),

              _campo(_nombre, 'Nombre completo', Icons.person_outline),
              const SizedBox(height: 16),

              _campo(_correo, 'Correo electrónico', Icons.email_outlined),
              const SizedBox(height: 16),

              _campo(
                _password,
                'Contraseña',
                Icons.lock_outline,
                secreto: true,
              ),
              const SizedBox(height: 16),

              _campo(
                _confirmar,
                'Confirmar contraseña',
                Icons.lock_reset,
                secreto: true,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _registrar,
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
                    'CREAR MI CUENTA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Ya tengo una cuenta',
                    style: TextStyle(color: dorado),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campo(
      TextEditingController controller,
      String etiqueta,
      IconData icono, {
        bool secreto = false,
      }) {
    return TextField(
      controller: controller,
      obscureText: secreto && !_mostrarPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: etiqueta,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icono, color: verde),
        suffixIcon: secreto
            ? IconButton(
          onPressed: () {
            setState(() {
              _mostrarPassword = !_mostrarPassword;
            });
          },
          icon: Icon(
            _mostrarPassword
                ? Icons.visibility_off
                : Icons.visibility,
            color: Colors.white54,
          ),
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
