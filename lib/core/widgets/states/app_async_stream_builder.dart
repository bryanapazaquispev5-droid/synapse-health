import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

import '../../services/connectivity_service.dart';

bool isContentAccessFailure(Object? error) =>
    error is FirebaseException &&
    ['permission-denied', 'unauthenticated'].contains(error.code);

/// Data already delivered by the stream is retained across transient failures.
class AppAsyncSnapshot<T> {
  const AppAsyncSnapshot({
    this.data,
    this.error,
    required this.hasData,
    required this.isWaiting,
    required this.isOnline,
    required this.isRetrying,
  });

  final T? data;
  final Object? error;
  final bool hasData;
  final bool isWaiting;
  final bool isOnline;
  final bool isRetrying;
  bool get hasError => error != null;
  bool get isAccessFailure => isContentAccessFailure(error);
}

/// Keeps its subscription mounted when connectivity changes. No disk cache added.
class AppAsyncStreamBuilder<T> extends StatefulWidget {
  const AppAsyncStreamBuilder({
    super.key,
    required this.stream,
    required this.builder,
    this.connectivity,
    this.onRetryStream,
  });

  final Stream<T> stream;
  final Widget Function(BuildContext, AppAsyncSnapshot<T>, VoidCallback)
  builder;
  final ConnectivityService? connectivity;
  final Stream<T> Function()? onRetryStream;

  @override
  State<AppAsyncStreamBuilder<T>> createState() =>
      _AppAsyncStreamBuilderState<T>();
}

class _AppAsyncStreamBuilderState<T> extends State<AppAsyncStreamBuilder<T>> {
  late final ConnectivityService _connectivity;
  StreamSubscription<T>? _subscription;
  StreamSubscription<bool>? _connectionSubscription;
  T? _data;
  Object? _error;
  bool _hasData = false;
  bool _waiting = true;
  bool _retrying = false;
  late bool _online;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _connectivity = widget.connectivity ?? ConnectivityService();
    _online = _connectivity.isOnline;
    _connectionSubscription = _connectivity.isOnlineStream.listen((online) {
      if (!mounted) return;
      final reconnected = !_online && online;
      setState(() => _online = online);
      if (reconnected && _error != null && !isContentAccessFailure(_error)) {
        _retry();
      }
    });
    _listen(widget.stream);
  }

  @override
  void didUpdateWidget(covariant AppAsyncStreamBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stream != oldWidget.stream) {
      _data = null;
      _hasData = false;
      _error = null;
      _waiting = true;
      _listen(widget.stream);
    }
  }

  Future<void> _listen(Stream<T> stream) async {
    final generation = ++_generation;
    // Cancellation detaches the listener immediately; transport cleanup may lag.
    // Generation checks prevent callbacks from the retired subscription.
    unawaited(
      _subscription?.cancel().catchError((Object error, StackTrace stack) {
        developer.log(
          'Subscription cleanup failed',
          name: 'AppAsyncStreamBuilder',
          error: error,
          stackTrace: stack,
        );
      }),
    );
    if (!mounted || generation != _generation) return;
    _subscription = stream.listen(
      (data) {
        if (!mounted || generation != _generation) return;
        setState(() {
          _data = data;
          _hasData = true; // A delivered null can mean no saved progress.
          _error = null;
          _waiting = false;
        });
      },
      onError: (Object error, StackTrace stack) {
        if (!mounted || generation != _generation) return;
        developer.log(
          'Content subscription failed',
          name: 'AppAsyncStreamBuilder',
          error: error,
          stackTrace: stack,
        );
        setState(() {
          _error = error;
          _waiting = false;
          if (isContentAccessFailure(error)) {
            _data = null;
            _hasData = false; // Never retain content after access is revoked.
          }
        });
      },
      onDone: () {
        if (!mounted ||
            generation != _generation ||
            _hasData ||
            _error != null) {
          return;
        }
        setState(() {
          _waiting = false;
          _error = StateError('Content stream ended without data');
        });
      },
    );
  }

  Future<void> _retry() async {
    if (_retrying) return;
    setState(() => _retrying = true);
    try {
      final online = await _connectivity.checkConnection();
      if (!mounted) return;
      setState(() {
        _online = online;
        _error = null;
        _waiting = true;
      });
      await _listen(widget.onRetryStream?.call() ?? widget.stream);
    } catch (error, stack) {
      developer.log(
        'Content retry failed',
        name: 'AppAsyncStreamBuilder',
        error: error,
        stackTrace: stack,
      );
      if (mounted) {
        setState(() {
          _error = error;
          _waiting = false;
        });
      }
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  @override
  void dispose() {
    _generation++;
    _subscription?.cancel();
    _connectionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(
    context,
    AppAsyncSnapshot<T>(
      data: _data,
      error: _error,
      hasData: _hasData,
      isWaiting: _waiting,
      isOnline: _online,
      isRetrying: _retrying,
    ),
    () => unawaited(_retry()),
  );
}
