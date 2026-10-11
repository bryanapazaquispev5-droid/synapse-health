import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/theme/app_theme.dart';
import 'package:synapse_health/features/quizzes/model/quiz_topic_progress_model.dart';
import 'package:synapse_health/features/quizzes/model/quiz_attempt_model.dart';
import 'package:synapse_health/features/quizzes/model/quiz_question_progress_model.dart';
import 'package:synapse_health/core/widgets/states/app_states.dart';
import 'package:synapse_health/features/cheatsheets/model/medical_area_model.dart';
import 'package:synapse_health/features/cheatsheets/model/topic_model.dart';
import 'package:synapse_health/features/quizzes/ui/widgets/quiz_topic_card.dart';
import 'package:synapse_health/features/quizzes/ui/widgets/quiz_topic_progress_badge.dart';

Widget card({bool ready = true, bool loading = false}) => MaterialApp(
  theme: AppTheme.lightTheme,
  home: Scaffold(
    body: QuizTopicCard(
      area: MedicalAreaModel(id: 'a', name: 'Área', code: 'A', order: 1),
      topic: const TopicModel(id: 't', areaId: 'a', title: 'Tema', order: 1),
      number: 1,
      progressIsAvailable: ready,
      isLoadingProgress: loading,
    ),
  ),
);

void main() {
  testWidgets('missing quiz count does not fabricate 20 quizzes', (
    tester,
  ) async {
    await tester.pumpWidget(card());
    expect(find.text('Ver quizzes'), findsOneWidget);
    expect(find.byType(QuizTopicProgressBadge), findsNothing);
    expect(find.textContaining('20'), findsNothing);
  });
  testWidgets(
    'loading progress keeps title visible without a zero-statistic badge',
    (tester) async {
      await tester.pumpWidget(card(ready: false, loading: true));
      expect(find.text('Tema'), findsOneWidget);
      expect(find.byType(AppLoadingState), findsOneWidget);
      expect(find.byType(QuizTopicProgressBadge), findsNothing);
    },
  );
  testWidgets('failed progress does not display metrics as an empty attempt', (
    tester,
  ) async {
    await tester.pumpWidget(card(ready: false));
    expect(find.text('Progreso no disponible'), findsOneWidget);
    expect(find.byType(AppLoadingState), findsNothing);
    expect(find.byType(QuizTopicProgressBadge), findsNothing);
  });
  testWidgets(
    'legacy progress without a known maximum never invents 20 stars',
    (tester) async {
      final progress = QuizTopicProgressModel.empty(topicId: 't', areaId: 'a')
          .copyWith(
            activeAttempt: QuizAttemptModel(
              attemptNumber: 1,
              startedAt: DateTime(2026),
              totalEarnedStars: 1,
              totalMaxStars: 0,
              questionAnswers: const {
                'q': QuizQuestionProgressModel(
                  quizId: 'q',
                  isAnswered: true,
                  isCorrect: true,
                  earnedStars: 1,
                  maxStars: 1,
                ),
              },
            ),
          );
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: QuizTopicProgressBadge(progress: progress, fallbackCount: 0),
          ),
        ),
      );
      expect(find.text('1 estrella'), findsOneWidget);
      expect(find.text('1/20'), findsNothing);
    },
  );
}
