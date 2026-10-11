import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/theme/app_theme.dart';
import 'package:synapse_health/features/cheatsheets/model/medical_area_model.dart';
import 'package:synapse_health/features/cheatsheets/model/topic_model.dart';
import 'package:synapse_health/features/personal_progress/api/personal_progress_repository.dart';
import 'package:synapse_health/features/personal_progress/ui/personal_progress_screen.dart';
import 'package:synapse_health/features/quizzes/model/quiz_attempt_model.dart';
import 'package:synapse_health/features/quizzes/model/quiz_question_progress_model.dart';
import 'package:synapse_health/features/quizzes/model/quiz_topic_progress_model.dart';

import '../../core/widgets/fixtures/async_content_fixture.dart';
import 'personal_progress_repository_fakes.dart';

class WidgetProgressRepository extends Fake
    implements PersonalProgressRepository {
  User? user = FakeIdentity('alice');
  final sessions = StreamController<User?>.broadcast();
  final sources =
      <String, StreamController<Map<String, QuizTopicProgressModel>>>{};
  int reads = 0;
  @override
  User? get currentUser => user;
  @override
  Stream<User?> get sessionChanges => sessions.stream;
  @override
  Stream<Map<String, QuizTopicProgressModel>> watchProgress(String uid) {
    reads++;
    return sources.putIfAbsent(uid, () => StreamController.broadcast()).stream;
  }

  @override
  Stream<List<MedicalAreaModel>> watchAreas(String uid) => Stream.value([
    MedicalAreaModel(id: 'a', name: 'Área de prueba', code: 'A', order: 1),
  ]);
  @override
  Stream<List<TopicModel>> watchTopics(String uid, String areaId) =>
      Stream.value([
        const TopicModel(
          id: 't',
          areaId: 'a',
          title: 'Tema de prueba',
          order: 1,
        ),
      ]);
  void changeUser(String? uid) {
    user = uid == null ? null : FakeIdentity(uid);
    sessions.add(user);
  }

  Future<void> close() async {
    await sessions.close();
    for (final source in sources.values) {
      await source.close();
    }
  }
}

QuizTopicProgressModel recordedProgress({int stars = 1, bool history = false}) {
  QuizAttemptModel attempt(int number, bool correct) => QuizAttemptModel(
    attemptNumber: number,
    startedAt: DateTime(2026, 10, 11),
    totalEarnedStars: correct ? stars : 0,
    totalMaxStars: stars,
    questionAnswers: {
      'q': QuizQuestionProgressModel(
        quizId: 'q',
        isAnswered: true,
        isCorrect: correct,
        earnedStars: correct ? stars : 0,
        maxStars: stars,
        answeredAt: DateTime(2026, 10, 11, 12, number),
      ),
    },
  );
  return QuizTopicProgressModel(
    topicId: 't',
    areaId: 'a',
    currentAttemptNumber: history ? 2 : 1,
    activeAttempt: attempt(history ? 2 : 1, true),
    history: history ? [attempt(1, false)] : [],
  );
}

Widget screen(
  WidgetProgressRepository repo,
  FakeConnectivity connection, {
  void Function(User)? ranking,
  TextScaler? textScaler,
}) => MaterialApp(
  theme: AppTheme.lightTheme,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: textScaler ?? TextScaler.noScaling),
    child: child!,
  ),
  home: PersonalProgressScreen(
    repository: repo,
    connectivity: connection,
    rankingBuilder: (user) {
      ranking?.call(user);
      return const Scaffold(body: Text('Ranking conservado'));
    },
  ),
);

Future<void> frames(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}
