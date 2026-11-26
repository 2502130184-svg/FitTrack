
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  // Comprobar si el dispositivo admite autenticación
  Future<bool> dispositivoCompatible() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  // Comprobar si existen huellas u otros datos biométricos registrados
  Future<bool> biometriaDisponible() async {
    try {
      final disponible = await _auth.canCheckBiometrics;
      final tipos = await _auth.getAvailableBiometrics();

      return disponible && tipos.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Obtener los tipos de autenticación disponibles
  Future<List<BiometricType>> obtenerBiometrias() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  // Solicitar autenticación mediante huella
  Future<bool> autenticar() async {
    try {
      final compatible = await dispositivoCompatible();
      final disponible = await biometriaDisponible();

      if (!compatible || !disponible) {
        return false;
      }

      return await _auth.authenticate(
        localizedReason:
        'Coloca tu huella dactilar para acceder a FitTrack.',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
}
