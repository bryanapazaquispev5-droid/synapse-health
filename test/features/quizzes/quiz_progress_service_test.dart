// Bloque: Pruebas Unitarias de Modelos de Progreso de Quizzes y Límite FIFO
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/features/quizzes/model/quiz_attempt_model.dart';
import 'package:synapse_health/features/quizzes/model/quiz_question_progress_model.dart';
import 'package:synapse_health/features/quizzes/model/quiz_topic_progress_model.dart';

void main() {
  group('QuizQuestionProgressModel Tests', () {
    test('Serialización y deserialización correcta toMap / fromMap', () {
      final now = DateTime.now();
      final model = QuizQuestionProgressModel(
        quizId: 'q_cardio_01',
        isAnswered: true,
        isCorrect: true,
        earnedStars: 3,
        maxStars: 3,
        selectedOptionIndex: 1,
        answeredAt: now,
      );

      final map = model.toMap();
      final deserialized = QuizQuestionProgressModel.fromMap(map);

      expect(deserialized.quizId, 'q_cardio_01');
      expect(deserialized.isAnswered, isTrue);
      expect(deserialized.isCorrect, isTrue);
      expect(deserialized.earnedStars, 3);
      expect(deserialized.maxStars, 3);
      expect(deserialized.selectedOptionIndex, 1);
      expect(deserialized.answeredAt?.year, now.year);
    });
  });

  group('QuizAttemptModel Tests', () {
    test('isQuizLocked y answeredCount reportan estados precisos', () {
      final q1 = QuizQuestionProgressModel(
        quizId: 'q1',
        isAnswered: true,
        isCorrect: true,
        earnedStars: 3,
        maxStars: 3,
      );

      final attempt = QuizAttemptModel(
        attemptNumber: 1,
        startedAt: DateTime.now(),
        totalEarnedStars: 3,
        totalMaxStars: 6,
        questionAnswers: {'q1': q1},
      );

      expect(attempt.isQuizLocked('q1'), isTrue);
      expect(attempt.isQuizLocked('q2'), isFalse);
      expect(attempt.answeredCount, 1);
      expect(attempt.getQuizProgress('q1')?.earnedStars, 3);
      expect(attempt.getQuizProgress('q2'), isNull);
    });
  });

  group('QuizTopicProgressModel & FIFO History Tests', () {
    test('empty factory inicializa con valores por defecto', () {
      final topicProgress = QuizTopicProgressModel.empty(
        topicId: 'topic_insuficiencia',
        areaId: 'area_cardiologia',
        totalMaxStars: 9,
      );

      expect(topicProgress.currentAttemptNumber, 1);
      expect(topicProgress.activeAttempt.totalEarnedStars, 0);
      expect(topicProgress.activeAttempt.totalMaxStars, 9);
      expect(topicProgress.history, isEmpty);
      expect(topicProgress.starsDisplay, '0 / 9');
      expect(topicProgress.starsPercentage, 0.0);
    });

    test('Límite estricto FIFO de 3 intentos históricos al reintentar', () {
      var progress = QuizTopicProgressModel.empty(
        topicId: 'topic_arritmias',
        areaId: 'area_cardiologia',
        totalMaxStars: 9,
      );

      QuizTopicProgressModel withStars(QuizTopicProgressModel p, int stars) {
        return p.copyWith(
          activeAttempt: p.activeAttempt.copyWith(
            totalEarnedStars: stars,
            questionAnswers: {
              'q1': const QuizQuestionProgressModel(
                quizId: 'q1', isAnswered: true, isCorrect: true, earnedStars: 3, maxStars: 3,
              ),
            },
          ),
        );
      }

      // Intento 1 -> Reintento 1 -> Historial: [1]
      progress = withStars(progress, 3).archiveCurrentAttemptAndReset(totalMaxStars: 9);
      expect(progress.currentAttemptNumber, 2);
      expect(progress.history.length, 1);
      expect(progress.history.first.attemptNumber, 1);
      expect(progress.history.first.totalEarnedStars, 3);

      // Intento 2 -> Reintento 2 -> Historial: [1, 2]
      progress = withStars(progress, 6).archiveCurrentAttemptAndReset(totalMaxStars: 9);
      expect(progress.currentAttemptNumber, 3);
      expect(progress.history.length, 2);
      expect(progress.history.map((e) => e.attemptNumber).toList(), [1, 2]);

      // Intento 3 -> Reintento 3 -> Historial: [1, 2, 3]
      progress = withStars(progress, 9).archiveCurrentAttemptAndReset(totalMaxStars: 9);
      expect(progress.currentAttemptNumber, 4);
      expect(progress.history.length, 3);
      expect(progress.history.map((e) => e.attemptNumber).toList(), [1, 2, 3]);

      // Intento 4 -> Reintento 4 -> FIFO descarta 1: [2, 3, 4]
      progress = withStars(progress, 7).archiveCurrentAttemptAndReset(totalMaxStars: 9);
      expect(progress.currentAttemptNumber, 5);
      expect(progress.history.length, 3);
      expect(progress.history.map((e) => e.attemptNumber).toList(), [2, 3, 4]);

      // Intento 5 -> Reintento 5 -> FIFO descarta 2: [3, 4, 5]
      progress = withStars(progress, 8).archiveCurrentAttemptAndReset(totalMaxStars: 9);
      expect(progress.currentAttemptNumber, 6);
      expect(progress.history.length, 3);
      expect(progress.history.map((e) => e.attemptNumber).toList(), [3, 4, 5]);
    });

    test('fromMap trunca a máximo 3 entradas si el payload de Firestore trae más', () {
      final rawMap = {
        'topicId': 't1',
        'areaId': 'a1',
        'currentAttemptNumber': 6,
        'activeAttempt': {
          'attemptNumber': 6,
          'startedAt': DateTime.now().toIso8601String(),
          'totalEarnedStars': 0,
          'totalMaxStars': 9,
          'questionAnswers': {},
        },
        'history': [
          {'attemptNumber': 1, 'startedAt': DateTime.now().toIso8601String(), 'totalEarnedStars': 3, 'totalMaxStars': 9, 'questionAnswers': {}},
          {'attemptNumber': 2, 'startedAt': DateTime.now().toIso8601String(), 'totalEarnedStars': 4, 'totalMaxStars': 9, 'questionAnswers': {}},
          {'attemptNumber': 3, 'startedAt': DateTime.now().toIso8601String(), 'totalEarnedStars': 5, 'totalMaxStars': 9, 'questionAnswers': {}},
          {'attemptNumber': 4, 'startedAt': DateTime.now().toIso8601String(), 'totalEarnedStars': 6, 'totalMaxStars': 9, 'questionAnswers': {}},
          {'attemptNumber': 5, 'startedAt': DateTime.now().toIso8601String(), 'totalEarnedStars': 7, 'totalMaxStars': 9, 'questionAnswers': {}},
        ],
      };

      final parsed = QuizTopicProgressModel.fromMap(rawMap);
      expect(parsed.history.length, 3);
      expect(parsed.history.map((e) => e.attemptNumber).toList(), [3, 4, 5]);
    });

    test('Cálculo de totalMax prioriza topicTotalMaxStars explícito', () {
      final updatedAnswers = {
        'q1': const QuizQuestionProgressModel(
          quizId: 'q1',
          isAnswered: true,
          isCorrect: true,
          earnedStars: 3,
          maxStars: 3,
        ),
      };

      int computeTotalMax(int? topicTotalMaxStars) {
        return (topicTotalMaxStars != null && topicTotalMaxStars > 0)
            ? topicTotalMaxStars
            : updatedAnswers.values.fold(0, (acc, q) => acc + q.maxStars);
      }

      expect(computeTotalMax(15), 15);
      expect(computeTotalMax(null), 3);
    });

    test('Cálculo de estrellas por área acumula solo temas de dicha área', () {
      final topics = {
        't1': QuizTopicProgressModel.empty(topicId: 't1', areaId: 'cardio')
            .copyWith(activeAttempt: QuizAttemptModel.empty().copyWith(totalEarnedStars: 5)),
        't2': QuizTopicProgressModel.empty(topicId: 't2', areaId: 'cardio')
            .copyWith(activeAttempt: QuizAttemptModel.empty().copyWith(totalEarnedStars: 4)),
        't3': QuizTopicProgressModel.empty(topicId: 't3', areaId: 'neuro')
            .copyWith(activeAttempt: QuizAttemptModel.empty().copyWith(totalEarnedStars: 6)),
      };

      int totalCardio = 0;
      for (final p in topics.values) {
        if (p.areaId == 'cardio') totalCardio += p.activeAttempt.totalEarnedStars;
      }
      expect(totalCardio, 9);
    });
  });
}
