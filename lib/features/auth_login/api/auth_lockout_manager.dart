// ============================================================================
// Archivo: auth_lockout_manager.dart
// Propósito: Servicio de autenticación con Firebase Auth, control de sesiones y llamadas a la API de seguridad.
// ============================================================================

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

/// Servicio de arquitectura y lógica de negocio para [AuthLockoutManager].
class AuthLockoutManager {
  int failedAttemptsCount = 0;
  int lockoutSeconds = 0;
  Timer? _lockoutTimer;

  Future<void> loadSecurityState({required Function(int created, int failed) onStateLoaded, required Function(int seconds) onLockoutUpdate}) async {
    // Bloque: Ejecución protegida de operación asíncrona
    try {
      final prefs = await SharedPreferences.getInstance();
      final created = prefs.getInt(AppConstants.PREF_CREATED_ACCOUNTS) ?? 0;
      final failed = prefs.getInt(AppConstants.PREF_FAILED_LOGIN_ATTEMPTS) ?? 0;
      final lockoutUntil = prefs.getInt(AppConstants.PREF_LOGIN_LOCKOUT_UNTIL) ?? 0;
      final nowInMs = DateTime.now().millisecondsSinceEpoch;

      failedAttemptsCount = failed;
      onStateLoaded(created, failed);

      if (lockoutUntil > nowInMs) {
        startLockoutTimer((lockoutUntil - nowInMs) ~/ 1000, onLockoutUpdate);
      }
    } catch (_) {}
  }

  void startLockoutTimer(int durationInSeconds, Function(int seconds) onUpdate) {
    _lockoutTimer?.cancel();
    lockoutSeconds = durationInSeconds;
    onUpdate(lockoutSeconds);

    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (lockoutSeconds <= 1) {
        timer.cancel();
        lockoutSeconds = 0;
        onUpdate(0);
      } else {
        lockoutSeconds--;
        onUpdate(lockoutSeconds);
      }
    });
  }

  Future<int?> recordFailedLogin(Function(int seconds) onLockoutUpdate) async {
    failedAttemptsCount++;
    // Bloque: Ejecución protegida de operación asíncrona
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppConstants.PREF_FAILED_LOGIN_ATTEMPTS, failedAttemptsCount);

      if (failedAttemptsCount >= 3) {
        int duration = AppConstants.LOCKOUT_TIER_1_SECONDS;
        if (failedAttemptsCount == 4) {
          duration = AppConstants.LOCKOUT_TIER_2_SECONDS;
        } else if (failedAttemptsCount >= 5) {
          duration = AppConstants.LOCKOUT_TIER_3_SECONDS;
        }

        final lockoutUntil = DateTime.now().millisecondsSinceEpoch + (duration * 1000);
        await prefs.setInt(AppConstants.PREF_LOGIN_LOCKOUT_UNTIL, lockoutUntil);
        startLockoutTimer(duration, onLockoutUpdate);
        return duration;
      }
    } catch (_) {}
    return null;
  }

  Future<void> clearLockout() async {
    failedAttemptsCount = 0;
    lockoutSeconds = 0;
    _lockoutTimer?.cancel();
    // Bloque: Ejecución protegida de operación asíncrona
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.PREF_FAILED_LOGIN_ATTEMPTS);
      await prefs.remove(AppConstants.PREF_LOGIN_LOCKOUT_UNTIL);
    } catch (_) {}
  }

  // Bloque: Liberación de recursos y controladores para evitar fugas de memoria
  void dispose() {
    _lockoutTimer?.cancel();
  }
}
