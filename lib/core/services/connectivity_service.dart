// ============================================================================
// Archivo: connectivity_service.dart
// Propósito: Servicio reactivo para monitorear el estado de conectividad a internet en tiempo real.
// ============================================================================

import 'dart:async';
import 'dart:io';

/// Servicio de arquitectura y lógica de negocio para [ConnectivityService].
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal() {
    _init();
  }

  final _controller = StreamController<bool>.broadcast();
  Stream<bool> get isOnlineStream => _controller.stream;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  Timer? _timer;

  void _init() {
    checkConnection();
    _timer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      checkConnection();
    });
  }

  Future<bool> checkConnection() async {
    // Bloque: Ejecución protegida de operación asíncrona
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(milliseconds: 2000));
      final bool isConnectionOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      _updateStatus(isConnectionOnline);
      return isConnectionOnline;
    } catch (_) {
      _updateStatus(false);
      return false;
    }
  }

  void _updateStatus(bool isOnline) {
    if (_isOnline != isOnline) {
      _isOnline = isOnline;
      _controller.add(isOnline);
    }
  }

  // Bloque: Liberación de recursos y controladores para evitar fugas de memoria
  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
