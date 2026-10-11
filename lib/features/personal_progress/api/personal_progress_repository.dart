import 'package:firebase_auth/firebase_auth.dart';

import '../../cheatsheets/api/medical_areas_service.dart';
import '../../cheatsheets/model/medical_area_model.dart';
import '../../cheatsheets/model/topic_model.dart';
import '../../quizzes/api/quiz_progress_service.dart';
import '../../quizzes/model/quiz_topic_progress_model.dart';

/// Read-only facade over existing services, bound to the active Auth identity.
class PersonalProgressRepository {
  PersonalProgressRepository({
    FirebaseAuth? auth,
    QuizProgressService? progressService,
    MedicalAreasService? catalog,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _progress = progressService ?? QuizProgressService(),
       _catalog = catalog ?? MedicalAreasService();

  final FirebaseAuth _auth;
  final QuizProgressService _progress;
  final MedicalAreasService _catalog;
  User? get currentUser => _auth.currentUser;
  Stream<User?> get sessionChanges => _auth.authStateChanges();

  Stream<T> _forOwner<T>(String uid, Stream<T> Function() load) {
    if (_auth.currentUser?.uid != uid) {
      return Stream.error(FirebaseAuthException(code: 'unauthenticated'));
    }
    return load().map((data) {
      if (_auth.currentUser?.uid != uid) {
        throw FirebaseAuthException(code: 'unauthenticated');
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
