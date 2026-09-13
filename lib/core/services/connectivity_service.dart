import 'dart:async';
import 'dart:io';

/// Servicio singleton para monitoreo de conexión a internet en tiempo real
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
    // Verificación continua cada 2.5 segundos
    _timer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      checkConnection();
    });
  }

  /// Comprueba la conectividad real haciendo una consulta DNS a Google
  Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(milliseconds: 2000));
      final online = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      _updateStatus(online);
      return online;
    } catch (_) {
      _updateStatus(false);
      return false;
    }
  }

  void _updateStatus(bool online) {
    if (_isOnline != online) {
      _isOnline = online;
      _controller.add(online);
    }
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
