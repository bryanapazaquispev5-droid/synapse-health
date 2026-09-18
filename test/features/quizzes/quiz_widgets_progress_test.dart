// Bloque: Pruebas de widgets de progreso, insignias y tarjetas de reintento de quiz
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/theme/app_theme.dart';
import 'package:synapse_health/features/quizzes/model/quiz_attempt_model.dart';
import 'package:synapse_health/features/quizzes/model/quiz_model.dart';
import 'package:synapse_health/features/quizzes/model/quiz_question_progress_model.dart';
import 'package:synapse_health/features/quizzes/model/quiz_topic_progress_model.dart';
import 'package:synapse_health/features/quizzes/ui/widgets/quiz_list_tile.dart';
import 'package:synapse_health/features/quizzes/ui/widgets/quiz_topic_progress_badge.dart';
import 'package:synapse_health/features/quizzes/ui/widgets/quiz_topic_retry_card.dart';

void main() {
  group('QuizTopicProgressBadge Tests', () {
    testWidgets('Muestra fallback cuando no hay progreso activo', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: QuizTopicProgressBadge(
              progress: null,
              fallbackCount: 15,
            ),
          ),
        ),
      );

      expect(find.text('15 Quizzes'), findsOneWidget);
      expect(find.text('⭐'), findsNothing);
    });

    testWidgets('Muestra estrellas cuando hay preguntas respondidas en el intento activo', (tester) async {
      final model = QuizTopicProgressModel(
        topicId: 'topic_1',
        areaId: 'area_1',
        currentAttemptNumber: 1,
        activeAttempt: QuizAttemptModel(
          attemptNumber: 1,
          startedAt: DateTime.now(),
          totalEarnedStars: 8,
          totalMaxStars: 10,
          questionAnswers: {
            'q1': QuizQuestionProgressModel(
              quizId: 'q1',
              isAnswered: true,
              isCorrect: true,
              earnedStars: 1,
              maxStars: 1,
            ),
          },
        ),
        history: const [],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: QuizTopicProgressBadge(
              progress: model,
              fallbackCount: 10,
            ),
          ),
        ),
      );

      expect(find.text('8/10'), findsOneWidget);
      expect(find.text('⭐'), findsOneWidget);
    });
  });

  group('QuizTopicRetryCard Tests', () {
    testWidgets('Renderiza información de intento, estrellas y botón de reintento', (tester) async {
      final model = QuizTopicProgressModel(
        topicId: 'topic_1',
        areaId: 'area_1',
        currentAttemptNumber: 2,
        activeAttempt: QuizAttemptModel(
          attemptNumber: 2,
          startedAt: DateTime.now(),
          totalEarnedStars: 5,
          totalMaxStars: 15,
          questionAnswers: {
            'q1': QuizQuestionProgressModel(
              quizId: 'q1',
              isAnswered: true,
              isCorrect: true,
              earnedStars: 1,
              maxStars: 1,
            ),
          },
        ),
        history: const [],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: QuizTopicRetryCard(
              progress: model,
              totalQuizzes: 15,
              totalMaxStars: 15,
              areaId: 'area_1',
              topicId: 'topic_1',
            ),
          ),
        ),
      );

      expect(find.text('Intento #2'), findsOneWidget);
      expect(find.text('5 / 15 estrellas'), findsOneWidget);
      expect(find.text('1 / 15 completadas'), findsOneWidget);
      expect(find.text('Reintentar tema'), findsOneWidget);
    });
  });

  group('QuizListTile Tests', () {
    final sampleQuiz = QuizModel(
      id: 'quiz_1',
      question: '¿Cuál es la arteria principal del brazo?',
      options: ['Arteria braquial', 'Arteria radial', 'Arteria femoral'],
      correctIndex: 0,
      rationale: 'La arteria braquial irriga el brazo.',
      sourceBook: 'Latarjet Anatomía',
      areaId: 'area_1',
      topicId: 'topic_1',
      type: 'multiple_choice',
    );

    testWidgets('Renderiza pregunta desbloqueada por defecto', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: QuizListTile(
              quiz: sampleQuiz,
              index: 1,
              allQuizzes: [sampleQuiz],
              areaTitle: 'Anatomía',
              questionProgress: null,
            ),
          ),
        ),
      );

      expect(find.text('Pregunta #1'), findsOneWidget);
      expect(find.text('¿Cuál es la arteria principal del brazo?'), findsOneWidget);
      expect(find.text('⭐'), findsNothing);
    });

    testWidgets('Renderiza estado bloqueado con estrellas cuando la pregunta fue respondida', (tester) async {
      final qProgress = QuizQuestionProgressModel(
        quizId: 'quiz_1',
        isAnswered: true,
        isCorrect: true,
        earnedStars: 1,
        maxStars: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: QuizListTile(
              quiz: sampleQuiz,
              index: 1,
              allQuizzes: [sampleQuiz],
              areaTitle: 'Anatomía',
              questionProgress: qProgress,
            ),
          ),
        ),
      );

      expect(find.text('⭐'), findsOneWidget);
      expect(find.text('1/1'), findsOneWidget);
    });

    testWidgets('Muestra snackbar al tocar cuando el intento no ha comenzado', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: QuizListTile(
              quiz: sampleQuiz,
              index: 1,
              allQuizzes: [sampleQuiz],
              areaTitle: 'Anatomía',
              questionProgress: null,
              isAttemptStarted: false,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(QuizListTile));
      await tester.pump();

      expect(find.text("Pulsa 'Comenzar Examen de Práctica' para iniciar el quiz del tema."), findsOneWidget);
    });
  });
}
