import 'dart:math';

import '../../../core/auth/app_auth.dart';
import '../../../core/api/aws_data_source.dart';
import '../model/quiz_topic_progress_model.dart';

/// Scoring, ownership, idempotency and attempt rotation are enforced by the API.
class QuizProgressService {
  QuizProgressService({AwsDataSource? source, AppAuth? auth})
    : source = source ?? AwsDataSource.instance,
      auth = auth ?? AppAuth.instance;
  final AwsDataSource source;
  final AppAuth auth;
  final _attempts = <String, int>{};
  String? _attemptOwner;
  void _bindOwner() {
    final uid = auth.currentUser?.uid;
    if (_attemptOwner != uid) { _attempts.clear(); _attemptOwner = uid; }
  }

  Stream<Map<String, QuizTopicProgressModel>> getAllTopicsProgressStream() {
    _bindOwner();
    if (auth.currentUser == null) return Stream.value(const {});
    return source.watch('api/v1/progress/me').map((data) {
      final progress = <String, QuizTopicProgressModel>{};
      for (final item in AwsDataSource.items(data)) {
        final model = QuizTopicProgressModel.fromMap(
          item,
          topicId: item['id'] as String?,
        );
        progress[model.topicId] = model;
        _attempts[model.topicId] = model.currentAttemptNumber;
      }
      return progress;
    });
  }

  Stream<QuizTopicProgressModel?> getTopicProgressStream(String topicId) =>
      getAllTopicsProgressStream().map((items) => items[topicId]);

  Stream<int> getAreaTotalStarsStream(String areaId) =>
      getAllTopicsProgressStream().map(
        (items) => items.values
            .where((item) => areaId.isEmpty || item.areaId == areaId)
            .fold(
              0,
              (total, item) => total + item.activeAttempt.totalEarnedStars,
            ),
      );

  Future<int> _attempt(String topicId) async {
    _bindOwner();
    if (auth.currentUser == null) {
      throw const AppAuthException('unauthenticated', 'Sign in.');
    }
    if (_attempts.containsKey(topicId)) return _attempts[topicId]!;
    final data = await source.api.requestData('GET', 'api/v1/progress/me');
    for (final item in AwsDataSource.items(data)) {
      _attempts[item['topicId'] as String? ?? item['id'] as String] =
          item['currentAttemptNumber'] as int? ?? 1;
    }
    return _attempts[topicId] ?? 1;
  }

  Future<void> recordQuestionAnswer({
    required String areaId,
    required String topicId,
    required String quizId,
    required bool isCorrect,
    required int earnedStars,
    required int maxStars,
    int? selectedOptionIndex,
    int? topicTotalMaxStars,
    Map<String, dynamic>? answer,
  }) async {
    if (answer == null) {
      throw ArgumentError('A raw answer is required for server scoring.');
    }
    await source.mutate('POST', 'api/v1/progress/$topicId/answer', {
      'areaId': areaId,
      'quizId': quizId,
      'answer': answer,
      'expectedAttemptNumber': await _attempt(topicId),
      'topicTotalMaxStars': ?topicTotalMaxStars,
    });
  }

  Future<void> retryTopic({
    required String areaId,
    required String topicId,
    required int totalMaxStars,
  }) async {
    final random = Random.secure();
    final key = List.generate(
      32,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();
    final data = await source.mutate('POST', 'api/v1/progress/$topicId/retry', {
      'areaId': areaId,
      'totalMaxStars': totalMaxStars,
      'expectedAttemptNumber': await _attempt(topicId),
      'idempotencyKey': key,
    });
    final progress = data['progress'];
    if (progress is Map<String, dynamic>) {
      _attempts[topicId] = progress['currentAttemptNumber'] as int;
    }
  }

  Future<void> resetAllProgress() async {
    _attempts.clear();
    await source.mutate('DELETE', 'api/v1/progress/me', {});
    await source.refreshAll();
  }
}
