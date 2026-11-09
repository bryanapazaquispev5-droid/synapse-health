import 'dart:async';

import '../auth/app_auth.dart';
import 'aws_api_client.dart';

/// Volatile, shared subscriptions. Only mounted consumers cause bounded polling.
class AwsDataSource {
  AwsDataSource({AwsApiClient? api}) : api = api ?? AwsApiClient();
  static final AwsDataSource instance = AwsDataSource();
  final AwsApiClient api;
  final _watches = <String, _Watch>{};

  Stream<Map<String, dynamic>> watch(String path) {
    final uid = AppAuth.instance.currentUser?.uid;
    final key = '$uid:$path';
    final existing = _watches[key];
    if (existing != null) return _subscribe(existing);
    late final _Watch watcher;
    Future<void> refresh() async {
      if (watcher.isLoading || watcher.controller.isClosed) return;
      watcher.isLoading = true;
      try {
        if (AppAuth.instance.currentUser?.uid != uid) {
          throw const AppAuthException('unauthenticated', 'Sign in.');
        }
        final data = await _readAll(
          path,
          onPartial: (partial) {
            if (!watcher.controller.isClosed &&
                AppAuth.instance.currentUser?.uid == uid) {
              watcher.lastData = partial;
              watcher.controller.add(partial);
            }
          },
        );
        if (!watcher.controller.isClosed &&
            AppAuth.instance.currentUser?.uid == uid) {
          watcher.lastData = data;
          watcher.controller.add(data);
        }
      } catch (error, stack) {
        if (!watcher.controller.isClosed) {
          watcher.controller.addError(error, stack);
        }
      } finally {
        watcher.isLoading = false;
      }
    }

    final controller = StreamController<Map<String, dynamic>>.broadcast(
      onListen: () {
        watcher.session = AppAuth.instance.authStateChanges().listen((user) {
          if (user?.uid != uid && !watcher.controller.isClosed) {
            watcher.lastData = null;
            watcher.timer?.cancel();
            watcher.controller.addError(
              const AppAuthException('unauthenticated', 'Sign in.'),
            );
          }
        });
        unawaited(refresh());
        watcher.timer = Timer.periodic(
          const Duration(seconds: 20),
          (_) => refresh(),
        );
      },
      onCancel: () {
        watcher.timer?.cancel();
        unawaited(watcher.session?.cancel());
        _watches.remove(key);
        unawaited(watcher.controller.close());
      },
    );
    watcher = _Watch(controller, refresh, uid);
    _watches[key] = watcher;
    return _subscribe(watcher);
  }

  Stream<Map<String, dynamic>> _subscribe(_Watch watcher) =>
      Stream.multi((sink) {
        final subscription = watcher.controller.stream.listen(
          sink.add,
          onError: sink.addError,
          onDone: sink.close,
        );
        if (AppAuth.instance.currentUser?.uid != watcher.owner) {
          sink.addError(const AppAuthException('unauthenticated', 'Sign in.'));
        } else if (watcher.lastData != null) {
          sink.add(watcher.lastData!);
        }
        sink.onCancel = subscription.cancel;
      });

  Future<Map<String, dynamic>> _readAll(
    String path, {
    void Function(Map<String, dynamic>)? onPartial,
  }) async {
    const pageSize = '50';
    final supportsPagination = path == 'api/v1/areas' ||
        path.startsWith('api/v1/areas/') ||
        path == 'api/v1/progress/me' ||
        path == 'api/v1/leaderboard';
    final first = await api.requestData(
      'GET',
      path,
      query: supportsPagination ? {'limit': pageSize} : null,
    );
    if (first['items'] is! List) return first;
    final all = [...items(first)];
    final cursors = <String>{};
    var cursor = first['nextCursor'];
    onPartial?.call({...first, 'items': List.of(all)});
    while (cursor != null) {
      if (cursor is! String || cursor.isEmpty || !cursors.add(cursor)) {
        throw const AwsApiException(ApiFailure.invalidResponse);
      }
      final next = await api.requestData(
        'GET',
        path,
        query: {'limit': pageSize, 'cursor': cursor},
      );
      all.addAll(items(next));
      cursor = next['nextCursor'];
      onPartial?.call({...first, 'items': List.of(all), 'nextCursor': cursor});
    }
    return {...first, 'items': all, 'nextCursor': null};
  }

  Future<void> refreshAll() async {
    await Future.wait(
      _watches.values.toList().map((watcher) => watcher.refresh()),
    );
  }

  Future<Map<String, dynamic>> mutate(
    String method,
    String path,
    Map<String, dynamic> body,
  ) async {
    final result = await api.requestData(method, path, body: body);
    for (final watcher in _watches.values.toList()) {
      unawaited(watcher.refresh());
    }
    return result;
  }

  static List<Map<String, dynamic>> items(Map<String, dynamic> data) {
    final items = data['items'];
    if (items is! List || items.any((item) => item is! Map<String, dynamic>)) {
      throw const AwsApiException(ApiFailure.invalidResponse);
    }
    return items.cast<Map<String, dynamic>>();
  }
}

class _Watch {
  _Watch(this.controller, this.refresh, this.owner);
  final String? owner;
  StreamSubscription<AppUser?>? session;
  final StreamController<Map<String, dynamic>> controller;
  final Future<void> Function() refresh;
  Timer? timer;
  bool isLoading = false;
  Map<String, dynamic>? lastData;
}
