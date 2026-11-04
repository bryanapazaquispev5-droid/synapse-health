import '../../../core/auth/app_auth.dart';

import '../../cheatsheets/api/medical_areas_service.dart';
import '../../cheatsheets/model/medical_area_model.dart';
import '../../cheatsheets/model/topic_model.dart';
import '../../quizzes/api/quiz_progress_service.dart';
import '../../quizzes/model/quiz_topic_progress_model.dart';

/// Read-only facade over existing services, bound to the active Auth identity.
class PersonalProgressRepository {
  PersonalProgressRepository({
    AppAuth? auth,
    QuizProgressService? progressService,
    MedicalAreasService? catalog,
  }) : _auth = auth ?? AppAuth.instance,
       _progress = progressService ?? QuizProgressService(),
       _catalog = catalog ?? MedicalAreasService();

  final AppAuth _auth;
  final QuizProgressService _progress;
  final MedicalAreasService _catalog;
  AppUser? get currentUser => _auth.currentUser;
  Stream<AppUser?> get sessionChanges => _auth.authStateChanges();

  Stream<T> _forOwner<T>(String uid, Stream<T> Function() load) {
    if (_auth.currentUser?.uid != uid) {
      return Stream.error(
        const AppAuthException('unauthenticated', 'Sign in.'),
      );
    }
    return load().map((data) {
      if (_auth.currentUser?.uid != uid) {
        throw const AppAuthException('unauthenticated', 'Sign in.');
      }
      return data;
    });
  }

  Stream<Map<String, QuizTopicProgressModel>> watchProgress(String uid) =>
      _forOwner(uid, _progress.getAllTopicsProgressStream);
  Stream<List<MedicalAreaModel>> watchAreas(String uid) =>
      _forOwner(uid, _catalog.getAreasStream);
  Stream<List<TopicModel>> watchTopics(String uid, String areaId) =>
      _forOwner(uid, () => _catalog.getTopicsStream(areaId));
}
