import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../models/quiz_model.dart';

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
}
