// Section: Widget tests for quiz progress, badges, and retry cards
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/theme/app_theme.dart';
import 'package:synapse_health/core/widgets/ios_top_banner.dart';
import 'package:synapse_health/features/quizzes/model/quiz_attempt_model.dart';
import 'package:synapse_health/features/quizzes/model/quiz_model.dart';
import 'package:synapse_health/features/quizzes/model/quiz_question_progress_model.dart';
import 'package:synapse_health/features/quizzes/model/quiz_topic_progress_model.dart';
import 'package:synapse_health/features/quizzes/ui/widgets/quiz_list_tile.dart';
import 'package:synapse_health/features/quizzes/ui/widgets/quiz_topic_progress_badge.dart';
import 'package:synapse_health/features/quizzes/ui/widgets/quiz_topic_retry_card.dart';

void main() {
  group('QuizTopicProgressBadge Tests', () {
    testWidgets('Shows the fallback when there is no active progress', (tester) async {
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

    testWidgets('Shows stars for questions answered in the active attempt', (tester) async {
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
    testWidgets('Renders attempt details, stars, and the retry button', (tester) async {
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

      expect(find.text('Attempt #2'), findsOneWidget);
      expect(find.text('5 / 15 stars'), findsOneWidget);
      expect(find.text('1 / 15 completed'), findsOneWidget);
      expect(find.text('Retry topic'), findsOneWidget);
    });
  });

  group('QuizListTile Tests', () {
    final sampleQuiz = QuizModel(
      id: 'quiz_1',
      question: 'What is the main artery of the arm?',
      options: ['Brachial artery', 'Radial artery', 'Femoral artery'],
      correctIndex: 0,
      rationale: 'The brachial artery supplies the arm.',
      sourceBook: 'Latarjet Anatomy',
      areaId: 'area_1',
      topicId: 'topic_1',
      type: 'multiple_choice',
    );

    testWidgets('Renders an unlocked question by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: QuizListTile(
              quiz: sampleQuiz,
              index: 1,
              allQuizzes: [sampleQuiz],
              areaTitle: 'Anatomy',
              questionProgress: null,
            ),
          ),
        ),
      );

      expect(find.text('Question #1'), findsOneWidget);
      expect(find.text('What is the main artery of the arm?'), findsOneWidget);
      expect(find.text('⭐'), findsNothing);
    });

    testWidgets('Renders the locked state with stars after the question is answered', (tester) async {
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
              areaTitle: 'Anatomy',
              questionProgress: qProgress,
            ),
          ),
        ),
      );

      expect(find.text('⭐'), findsOneWidget);
      expect(find.text('1/1'), findsOneWidget);
    });

    testWidgets('Shows a snackbar when tapped before the attempt has started', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: QuizListTile(
              quiz: sampleQuiz,
              index: 1,
              allQuizzes: [sampleQuiz],
              areaTitle: 'Anatomy',
              questionProgress: null,
              isAttemptStarted: false,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(QuizListTile));
      await tester.pump();

      expect(find.text("Tap 'Start Practice Exam' to begin this topic quiz."), findsOneWidget);
      IosTopBanner.dismiss();
      await tester.pump();
    });
  });
}
