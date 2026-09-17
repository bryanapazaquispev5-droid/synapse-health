// ============================================================================
// Archivo: app_settings_service.dart
// Propósito: Servicio para la lectura y persistencia de preferencias y ajustes generales de la aplicacion.
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Servicio para la gestion de operaciones de [AppSettingsService]
class AppSettingsService {
  static final AppSettingsService _instance = AppSettingsService._internal();
  factory AppSettingsService() => _instance;
  AppSettingsService._internal();

  static const String _keyLiquidWave = 'key_liquid_wave_transition_enabled';

  final ValueNotifier<bool> isLiquidWaveEnabled = ValueNotifier<bool>(false);

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isLiquidWaveEnabled.value = prefs.getBool(_keyLiquidWave) ?? false;
    } catch (_) {
      isLiquidWaveEnabled.value = false;
    }
  }

  Future<void> setLiquidWaveEnabled(bool enabled) async {
    isLiquidWaveEnabled.value = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyLiquidWave, enabled);
    } catch (_) {}
  }
}
