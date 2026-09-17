// ============================================================================
// Archivo: quiz_service.dart
// Propósito: Servicio para la recuperacion de reactivos y guardado de calificaciones de cuestionarios en Firestore.
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../model/quiz_model.dart';

// Servicio para la gestion de operaciones de [QuizService]
class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtiene en tiempo real los quizzes asociados a un área médica específica
  Stream<List<QuizModel>> getQuizzesByAreaStream(String areaId) {
    return _firestore
        .collection(AppConstants.firestoreMedicalAreas)
        .doc(areaId)
        .collection(AppConstants.firestoreQuizzes)
        .snapshots()
        .map((snapshot) {
      final quizzes = snapshot.docs
          .map((doc) => QuizModel.fromMap(doc.data(), doc.id))
          .toList();

      quizzes.sort((a, b) => a.order.compareTo(b.order));
      return quizzes;
    });
  }

  /// Obtiene en tiempo real los quizzes asociados a un tema específico
  Stream<List<QuizModel>> getQuizzesByTopicStream(String areaId, String topicId) {
    return _firestore
        .collection(AppConstants.firestoreMedicalAreas)
        .doc(areaId)
        .collection(AppConstants.firestoreTopics)
        .doc(topicId)
        .collection(AppConstants.firestoreQuizzes)
        .snapshots()
        .asyncMap((topicSnapshot) async {
      if (topicSnapshot.docs.isNotEmpty) {
        final quizzes = topicSnapshot.docs
            .map((doc) => QuizModel.fromMap(doc.data(), doc.id))
            .toList();
        quizzes.sort((a, b) => a.order.compareTo(b.order));
        return quizzes;
      }
      final areaSnapshot = await _firestore
          .collection(AppConstants.firestoreMedicalAreas)
          .doc(areaId)
          .collection(AppConstants.firestoreQuizzes)
          .where('topicId', isEqualTo: topicId)
          .get();

      final quizzes = areaSnapshot.docs
          .map((doc) => QuizModel.fromMap(doc.data(), doc.id))
          .toList();
      quizzes.sort((a, b) => a.order.compareTo(b.order));
      return quizzes;
    });
  }
}
