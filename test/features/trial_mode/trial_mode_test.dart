import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:synapse_health/features/auth_login/model/trial_mode_session.dart';
import 'package:synapse_health/features/quizzes/api/quiz_session_persistence.dart';
import 'package:synapse_health/features/trial_mode/data/trial_content.dart';
import 'package:synapse_health/features/trial_mode/ui/trial_mode_screen.dart';

void main() {
  tearDown(TrialModeSession.end);

  test(
    'trial content is limited to one topic, two notes, and one quiz question',
    () {
      expect(TrialContent.area.topicsCount, 1);
      expect(TrialContent.topic.areaId, TrialContent.area.id);
      expect(TrialContent.notes, hasLength(2));
      expect(TrialContent.quizLevelOne, hasLength(1));
      expect(TrialContent.quizLevelOne.single.topicId, TrialContent.topic.id);
    },
  );

  test('trial quiz answer is not sent to AWS progress persistence', () async {
    TrialModeSession.start();
    await QuizSessionPersistence().record(
      TrialContent.quizLevelOne.single,
      isCorrect: true,
      earnedStars: 1,
      maxStars: 1,
      totalMaxStars: 1,
      selectedOptionIndex: 1,
    );
    expect(TrialModeSession.isActive, isTrue);
  });

  testWidgets('trial screen shows only the local notes and quiz level', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TrialModeScreen()));
    expect(find.text('Anatomical Basics'), findsOneWidget);
    expect(find.text('Anatomical Position'), findsOneWidget);
    expect(find.text('Body Planes and Sections'), findsOneWidget);
    expect(find.text('Level 1 · Anatomical Position'), findsOneWidget);
    expect(find.text('User Progress'), findsNothing);
  });
}
