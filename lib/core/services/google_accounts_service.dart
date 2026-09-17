// ============================================================================
// Archivo: google_accounts_service.dart
// Propósito: Servicio para la gestion y consulta de cuentas de Google vinculadas al dispositivo.
// ============================================================================

import 'package:flutter/services.dart';

/// Servicio para interactuar con las cuentas Google del dispositivo
/// mediante el AccountManager nativo de Android.
class GoogleAccountsService {
  static const _channel = MethodChannel('com.synapse_health/google_accounts');

  /// Retorna la lista de emails de cuentas Google en el dispositivo.
  static Future<List<String>> getDeviceGoogleAccounts() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getGoogleAccounts');
      return result.cast<String>();
    } on PlatformException {
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Obtiene un token OAuth2 de Google para el [email] indicado
  /// directamente desde el AccountManager de Android — sin abrir el
  /// selector nativo de Google si la cuenta ya está en el dispositivo.
  ///
  /// Retorna el token, o `null` si falla (en ese caso usar el flujo normal).
  static Future<String?> getGoogleAuthToken(String email) async {
    try {
      final String? token = await _channel.invokeMethod(
        'getGoogleAuthToken',
        {'email': email},
      );
      return token;
    } on PlatformException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
