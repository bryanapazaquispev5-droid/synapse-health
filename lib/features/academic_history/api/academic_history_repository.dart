import '../../../core/auth/app_auth.dart';

import '../../../core/api/aws_api_client.dart';

import '../../cheatsheets/model/medical_area_model.dart';
import '../../cheatsheets/model/topic_model.dart';
import '../../personal_progress/api/personal_progress_repository.dart';
import '../../quizzes/api/quiz_service.dart';
import '../../quizzes/model/quiz_model.dart';
import '../model/academic_history_entry.dart';
import '../utils/academic_history_builder.dart';
import 'aws_history_pages.dart';

/// Private academic history uses the authenticated AWS API.
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
  AppUser? get currentUser => _progress.currentUser;
  Stream<AppUser?> get sessionChanges => _progress.sessionChanges;
  bool get usesAwsApi => true;
  final _pages = <String, AwsHistoryPages>{};
  bool hasMore(String uid) => usesAwsApi && (_pages[uid]?.hasMore ?? false);
  Future<void> loadMore(String uid) async {
    _requireOwner(uid);
    await _pages[uid]?.loadMore();
  }

  void _requireOwner(String uid) {
    if (currentUser?.uid != uid) {
      throw const AppAuthException('unauthenticated', 'Sign in.');
    }
  }

  Stream<List<AcademicHistoryEntry>> watchHistory(String uid) async* {
    _requireOwner(uid);
    if (!usesAwsApi) {
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
      mapFailure: (error) => error,
      onCancel: () {
        if (identical(_pages[uid], pages)) _pages.remove(uid);
      },
    );
    _pages[uid] = pages;
    yield* pages.stream;
  }

  Stream<List<AcademicHistoryEntry>> watchEntry(String uid, String id) async* {
    _requireOwner(uid);
    if (!usesAwsApi) {
      yield* watchHistory(uid).map((entries) {
        final entry = findAcademicHistoryEntry(entries, id);
        return entry == null ? <AcademicHistoryEntry>[] : [entry];
      });
      return;
    }
    try {
      yield [await fetchEntry(uid, id)];
    } on AwsApiException catch (error) {
      if (error.failure != ApiFailure.notFound) rethrow;
      yield const <AcademicHistoryEntry>[];
    }
  }

  Future<AcademicHistoryEntry> fetchEntry(String uid, String id) async {
    _requireOwner(uid);
    if (usesAwsApi) {
      final data = await _api.fetchHistoryEntry(id);
      _requireOwner(uid);
      return AcademicHistoryEntry.fromJson(data);
    }
    final entries = await watchHistory(uid).first;
    _requireOwner(uid);
    final entry = findAcademicHistoryEntry(entries, id);
    if (entry == null) {
      throw const AwsApiException(ApiFailure.notFound);
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
}
