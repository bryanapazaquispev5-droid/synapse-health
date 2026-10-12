import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/api/aws_api_client.dart';
import '../../cheatsheets/model/medical_area_model.dart';
import '../../cheatsheets/model/topic_model.dart';
import '../../personal_progress/api/personal_progress_repository.dart';
import '../../quizzes/api/quiz_service.dart';
import '../../quizzes/model/quiz_model.dart';
import '../model/academic_history_entry.dart';
import '../utils/academic_history_builder.dart';
import 'aws_history_pages.dart';

/// An explicit transition boundary; Firebase remains authoritative until AWS is configured.
class AcademicHistoryRepository {
  AcademicHistoryRepository({
    PersonalProgressRepository? progress,
    QuizService? quizzes,
    AwsApiClient? api,
  }) : _progress = progress ?? PersonalProgressRepository(),
       _quizzes = quizzes ?? QuizService(),
       _api = api ?? AwsApiClient();

  final PersonalProgressRepository _progress;
  final QuizService _quizzes;
  final AwsApiClient _api;
  User? get currentUser => _progress.currentUser;
  Stream<User?> get sessionChanges => _progress.sessionChanges;
  bool get usesAws => _api.isConfigured;
  final _pages = <String, AwsHistoryPages>{};
  bool hasMore(String uid) => usesAws && (_pages[uid]?.hasMore ?? false);
  Future<void> loadMore(String uid) async {
    _requireOwner(uid);
    await _pages[uid]?.loadMore();
  }

  void _requireOwner(String uid) {
    if (currentUser?.uid != uid) {
      throw FirebaseAuthException(code: 'unauthenticated');
    }
  }

  Stream<List<AcademicHistoryEntry>> watchHistory(String uid) async* {
    _requireOwner(uid);
    if (!usesAws) {
      yield* _progress.watchProgress(uid).map((topics) {
        _requireOwner(uid);
        return buildAcademicHistory(topics);
      });
      return;
    }
    // First page is immediate; subsequent pages require the visible More action.
    late final AwsHistoryPages pages;
    pages = AwsHistoryPages(
      api: _api,
      requireOwner: () => _requireOwner(uid),
      mapFailure: (error) =>
          error is AwsApiException ? _contentFailure(error) : error,
      onCancel: () {
        if (identical(_pages[uid], pages)) _pages.remove(uid);
      },
    );
    _pages[uid] = pages;
    yield* pages.stream;
  }

  Stream<List<AcademicHistoryEntry>> watchEntry(String uid, String id) async* {
    _requireOwner(uid);
    if (!usesAws) {
      yield* watchHistory(uid).map((entries) {
        final entry = findAcademicHistoryEntry(entries, id);
        return entry == null ? <AcademicHistoryEntry>[] : [entry];
      });
      return;
    }
    try {
      yield [await fetchEntry(uid, id)];
    } on FirebaseException catch (error) {
      if (error.code != 'not-found') rethrow;
      yield const <AcademicHistoryEntry>[];
    }
  }

  Future<AcademicHistoryEntry> fetchEntry(String uid, String id) async {
    _requireOwner(uid);
    if (usesAws) {
      try {
        final data = await _api.fetchHistoryEntry(id);
        _requireOwner(uid);
        return AcademicHistoryEntry.fromJson(data);
      } on AwsApiException catch (error) {
        throw _contentFailure(error);
      }
    }
    final entries = await watchHistory(uid).first;
    _requireOwner(uid);
    final entry = findAcademicHistoryEntry(entries, id);
    if (entry == null) {
      throw FirebaseException(plugin: 'synapse-api', code: 'not-found');
    }
    return entry;
  }

  Stream<List<MedicalAreaModel>> watchAreas(String uid) =>
      _progress.watchAreas(uid);
  Stream<List<TopicModel>> watchTopics(String uid, String areaId) =>
      _progress.watchTopics(uid, areaId);
  Stream<List<QuizModel>> watchQuizzes(
    String uid,
    String areaId,
    String topicId,
  ) {
    _requireOwner(uid);
    return _quizzes.getQuizzesByTopicStream(areaId, topicId).map((data) {
      _requireOwner(uid);
      return data;
    });
  }

  FirebaseException _contentFailure(AwsApiException error) => FirebaseException(
    plugin: 'synapse-api',
    code: switch (error.failure) {
      ApiFailure.unauthenticated => 'unauthenticated',
      ApiFailure.forbidden => 'permission-denied',
      ApiFailure.offline => 'network-request-failed',
      ApiFailure.timeout => 'deadline-exceeded',
      ApiFailure.notFound => 'not-found',
      ApiFailure.rateLimited => 'resource-exhausted',
      _ => 'backend-error',
    },
  );
}
