import 'dart:async';

import '../../../core/api/aws_api_client.dart';
import '../model/academic_history_entry.dart';

/// One live subscription owns its paginated snapshot; cancellation clears it.
class AwsHistoryPages {
  AwsHistoryPages({
    required this.api,
    required this.requireOwner,
    required this.mapFailure,
    required this.onCancel,
  }) {
    _controller = StreamController<List<AcademicHistoryEntry>>(
      onListen: () => unawaited(loadMore()),
      onCancel: () {
        _cancelled = true;
        _entries.clear();
        onCancel();
        unawaited(_controller.close());
      },
    );
  }
  final AwsApiClient api;
  final void Function() requireOwner;
  final Object Function(Object) mapFailure;
  final void Function() onCancel;
  late final StreamController<List<AcademicHistoryEntry>> _controller;
  final _entries = <AcademicHistoryEntry>[];
  final _cursors = <String>{};
  final _ids = <String>{};
  String? _cursor;
  bool _cancelled = false;
  bool hasMore = true;
  Future<void>? _pending;
  Stream<List<AcademicHistoryEntry>> get stream => _controller.stream;

  Future<void> loadMore() =>
      _pending ??= _load().whenComplete(() => _pending = null);
  Future<void> _load() async {
    if (_cancelled || !hasMore) return;
    try {
      requireOwner();
      final page = await api.fetchHistoryPage(cursor: _cursor);
      requireOwner();
      if (_cancelled) return;
      final items = page['items'];
      final next = page['nextCursor'];
      if (items is! List || (next != null && next is! String)) {
        throw const AwsApiException(ApiFailure.invalidResponse);
      }
      final batch = <AcademicHistoryEntry>[];
      final batchIds = <String>{};
      for (final item in items) {
        if (item is! Map<String, dynamic>) {
          throw const AwsApiException(ApiFailure.invalidResponse);
        }
        final entry = AcademicHistoryEntry.fromJson(item);
        if (_ids.contains(entry.id) || !batchIds.add(entry.id)) {
          throw const AwsApiException(ApiFailure.invalidResponse);
        }
        batch.add(entry);
      }
      if (_entries.length + batch.length > 10000 ||
          (next != null && !_cursors.add(next as String))) {
        throw const AwsApiException(ApiFailure.invalidResponse);
      }
      _entries.addAll(batch);
      _ids.addAll(batchIds);
      _cursor = next as String?;
      hasMore = next != null;
      _controller.add(List.unmodifiable(_entries));
    } catch (error, trace) {
      if (!_cancelled) _controller.addError(mapFailure(error), trace);
    }
  }
}
