// ============================================================================
// Archivo: performance_service.dart
// Propósito: Medición de rendimiento, latencia de red y trazas personalizadas mediante Firebase Performance Monitoring.
// ============================================================================

import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

/// Servicio de arquitectura y lógica de negocio para [PerformanceService].
class PerformanceService {
  static final FirebasePerformance _instance = FirebasePerformance.instance;

  static Future<void> initialize() async {
    await _instance.setPerformanceCollectionEnabled(!kDebugMode);
  }

  static Future<Trace> startCustomTrace(String traceName) async {
    final trace = _instance.newTrace(traceName);
    await trace.start();
    return trace;
  }

  static Future<T> measureAsyncOperation<T>({
    required String traceName,
    required Future<T> Function() operation,
    Map<String, String>? attributes,
  }) async {
    final trace = await startCustomTrace(traceName);
    if (attributes != null) {
      for (final entry in attributes.entries) {
        trace.putAttribute(entry.key, entry.value);
      }
    }
    // Bloque: Ejecución protegida de operación asíncrona
    try {
      final result = await operation();
      return result;
    } finally {
      await trace.stop();
    }
  }
}
