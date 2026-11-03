// ============================================================================
// File: connectivity_service.dart
// Purpose: Reactive service for monitoring internet connectivity and detecting offline/online transitions.
// ============================================================================

import 'dart:async';
import 'dart:developer' as developer;

import 'internet_connection_probe.dart';

/// Singleton service for real-time internet connectivity monitoring
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
  Future<bool>? _pendingCheck;

  void _init() {
    _checkInBackground();
    // Continuous check every 2.5 seconds
    _timer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      _checkInBackground();
    });
  }

  /// Coalesces checks so polling and retry never start overlapping probes.
  Future<bool> checkConnection() {
    return _pendingCheck ??= probeInternetConnection()
        .then((online) {
          _updateStatus(online);
          return online;
        })
        .whenComplete(() => _pendingCheck = null);
  }

  void _checkInBackground() {
    unawaited(
      checkConnection().catchError((Object error, StackTrace stack) {
        developer.log(
          'Unexpected connectivity failure',
          name: 'ConnectivityService',
          error: error,
          stackTrace: stack,
        );
        return _isOnline; // An internal error is not evidence of being offline.
      }),
    );
  }

  void _updateStatus(bool isOnline) {
    if (!_controller.isClosed && _isOnline != isOnline) {
      _isOnline = isOnline;
      _controller.add(isOnline);
    }
  }

  // Release controllers and resources to prevent memory leaks
  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
