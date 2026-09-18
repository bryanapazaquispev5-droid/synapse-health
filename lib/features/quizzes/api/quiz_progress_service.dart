// Bloque: Servicio de Gestión de Progreso, Estrellas y Reintentos de Quizzes
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_constants.dart';
import '../model/quiz_question_progress_model.dart';
import '../model/quiz_topic_progress_model.dart';

class QuizProgressService {
  // Bloque: Instancia singleton y dependencias inyectables
  static final QuizProgressService _instance = QuizProgressService._internal();
  factory QuizProgressService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) {
    if (firestore != null || auth != null) {
      return QuizProgressService._internal(
        firestore: firestore,
        auth: auth,
      );
    }
    return _instance;
  }

  QuizProgressService._internal({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const String _collectionPath = 'quiz_topics_progress';

  // Bloque: Helper para obtener la referencia de la subcolección del usuario
  CollectionReference<Map<String, dynamic>>? _getUserProgressCollection() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore
        .collection(AppConstants.FIRESTORE_USERS)
        .doc(uid)
        .collection(_collectionPath);
  }

  // Bloque: Stream del progreso de un tema específico
  Stream<QuizTopicProgressModel?> getTopicProgressStream(String topicId) {
    final collection = _getUserProgressCollection();
    if (collection == null) {
      return Stream.value(null);
    }

    return collection.doc(topicId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return QuizTopicProgressModel.fromMap(
        snapshot.data()!,
        topicId: topicId,
      );
    });
  }

  // Bloque: Stream de todos los progresos de temas del usuario
  Stream<Map<String, QuizTopicProgressModel>> getAllTopicsProgressStream() {
    final collection = _getUserProgressCollection();
    if (collection == null) {
      return Stream.value(const {});
    }

    return collection.snapshots().map((snapshot) {
      final Map<String, QuizTopicProgressModel> map = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        map[doc.id] = QuizTopicProgressModel.fromMap(data, topicId: doc.id);
      }
      return map;
    });
  }

  // Bloque: Stream del total de estrellas acumuladas para un área específica
  Stream<int> getAreaTotalStarsStream(String areaId) {
    return getAllTopicsProgressStream().map((topicsMap) {
      int total = 0;
      for (final progress in topicsMap.values) {
        if (progress.areaId == areaId || areaId.isEmpty) {
          total += progress.activeAttempt.totalEarnedStars;
        }
      }
      return total;
    });
  }

  // Bloque: Registrar respuesta de una pregunta individual y actualizar estrellas
  Future<void> recordQuestionAnswer({
    required String areaId,
    required String topicId,
    required String quizId,
    required bool isCorrect,
    required int earnedStars,
    required int maxStars,
    int? selectedOptionIndex,
    int? topicTotalMaxStars,
  }) async {
    try {
      final collection = _getUserProgressCollection();
      if (collection == null) {
        developer.log(
          'Usuario no autenticado para registrar respuesta en quiz: $quizId',
          name: 'QuizProgressService',
        );
        return;
      }

      final docRef = collection.doc(topicId);
      final snapshot = await docRef.get();

      QuizTopicProgressModel model;
      if (snapshot.exists && snapshot.data() != null) {
        model = QuizTopicProgressModel.fromMap(
          snapshot.data()!,
          topicId: topicId,
          areaId: areaId,
        );
      } else {
        model = QuizTopicProgressModel.empty(
          topicId: topicId,
          areaId: areaId,
        );
      }

      // Bloque: Crear entrada de respuesta para la pregunta actual
      final questionProgress = QuizQuestionProgressModel(
        quizId: quizId,
        isAnswered: true,
        isCorrect: isCorrect,
        earnedStars: earnedStars,
        maxStars: maxStars,
        selectedOptionIndex: selectedOptionIndex,
        answeredAt: DateTime.now(),
      );

      final updatedAnswers = Map<String, QuizQuestionProgressModel>.from(
        model.activeAttempt.questionAnswers,
      );
      updatedAnswers[quizId] = questionProgress;

      // Bloque: Recalcular estrellas acumuladas del intento activo
      final int totalEarned = updatedAnswers.values.fold(
        0,
        (acc, q) => acc + q.earnedStars,
      );

      final int totalMax = (topicTotalMaxStars != null && topicTotalMaxStars > 0)
          ? topicTotalMaxStars
          : (model.activeAttempt.totalMaxStars > updatedAnswers.length
              ? model.activeAttempt.totalMaxStars
              : updatedAnswers.values.fold(0, (acc, q) => acc + q.maxStars));

      final updatedAttempt = model.activeAttempt.copyWith(
        questionAnswers: updatedAnswers,
        totalEarnedStars: totalEarned,
        totalMaxStars: totalMax,
      );

      final updatedModel = model.copyWith(
        activeAttempt: updatedAttempt,
        updatedAt: DateTime.now(),
      );

      await docRef.set(updatedModel.toMap(), SetOptions(merge: true));
    } catch (e, stackTrace) {
      developer.log(
        'Error registrando respuesta de quiz: $e',
        name: 'QuizProgressService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Bloque: Reintentar tema archivando intento actual con regla estricta FIFO de 3
  Future<void> retryTopic({
    required String areaId,
    required String topicId,
    required int totalMaxStars,
  }) async {
    try {
      final collection = _getUserProgressCollection();
      if (collection == null) return;

      final docRef = collection.doc(topicId);
      final snapshot = await docRef.get();

      if (!snapshot.exists || snapshot.data() == null) {
        final initialModel = QuizTopicProgressModel.empty(
          topicId: topicId,
          areaId: areaId,
          totalMaxStars: totalMaxStars,
        );
        await docRef.set(initialModel.toMap());
        return;
      }

      final model = QuizTopicProgressModel.fromMap(
        snapshot.data()!,
        topicId: topicId,
        areaId: areaId,
      );

      // Bloque: Si el intento actual contiene respuestas, archivarlo con FIFO estricto
      if (model.activeAttempt.questionAnswers.isNotEmpty) {
        final resetModel = model.archiveCurrentAttemptAndReset(
          totalMaxStars: totalMaxStars,
        );
        await docRef.set(resetModel.toMap());
      } else {
        // Bloque: Si estaba vacío, solo actualizar configuración de estrellas
        final updatedAttempt = model.activeAttempt.copyWith(
          totalMaxStars: totalMaxStars,
        );
        await docRef.set(
          model.copyWith(activeAttempt: updatedAttempt).toMap(),
          SetOptions(merge: true),
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error reintentando tema de quiz: $e',
        name: 'QuizProgressService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
