// ============================================================================
// Archivo: google_accounts_service.dart
// Propósito: Servicio de consulta y selección de cuentas de Google autenticadas en el dispositivo.
// ============================================================================

import 'package:flutter/services.dart';

/// Servicio de arquitectura y lógica de negocio para [GoogleAccountsService].
class GoogleAccountsService {
  static const _channel = MethodChannel('com.synapse_health/google_accounts');

  static Future<List<String>> getDeviceGoogleAccounts() async {
    // Bloque: Ejecución protegida de operación asíncrona
    try {
      final List<dynamic> result = await _channel.invokeMethod('getGoogleAccounts');
      return result.cast<String>();
    } on PlatformException {
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<String?> getGoogleAuthToken(String email) async {
    // Bloque: Ejecución protegida de operación asíncrona
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
