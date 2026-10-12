import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/theme/app_theme.dart';
import 'package:synapse_health/features/academic_history/api/academic_history_repository.dart';
import 'package:synapse_health/features/academic_history/model/academic_history_entry.dart';
import 'package:synapse_health/features/academic_history/ui/academic_history_screen.dart';
import 'package:synapse_health/features/cheatsheets/model/medical_area_model.dart';
import 'package:synapse_health/features/cheatsheets/model/topic_model.dart';
import 'package:synapse_health/features/quizzes/model/quiz_model.dart';

import '../../core/widgets/fixtures/async_content_fixture.dart';

class HistoryTestUser extends Fake implements User {
  HistoryTestUser(this.uid);
  @override
  final String uid;
}

class HistoryScreenRepository extends Fake
    implements AcademicHistoryRepository {
  User? user = HistoryTestUser('alice');
  final sessions = StreamController<User?>.broadcast();
  final histories = <String, StreamController<List<AcademicHistoryEntry>>>{};
  final historyReads = <String>[];
  int areaReads = 0, topicReads = 0, quizReads = 0;
  bool hasCatalog = true;
  bool hasNextPage = false;
  int pageLoads = 0;
  List<AcademicHistoryEntry> nextEntries = [];
  Completer<void>? pageGate;
  String areaName = 'Área de prueba';
  Object? catalogError;
  @override
  User? get currentUser => user;
  @override
  Stream<User?> get sessionChanges => sessions.stream;
  @override
  Stream<List<AcademicHistoryEntry>> watchHistory(String uid) {
    historyReads.add(uid);
    return histories
        .putIfAbsent(uid, () => StreamController.broadcast())
        .stream;
  }

  @override
  bool hasMore(String uid) => hasNextPage;
  @override
  Future<void> loadMore(String uid) async {
    pageLoads++;
    await pageGate?.future;
    hasNextPage = false;
    histories[uid]!.add(nextEntries);
  }

  @override
  Stream<List<AcademicHistoryEntry>> watchEntry(String uid, String id) =>
      watchHistory(uid)
          .map((entries) => entries.where((entry) => entry.id == id).toList());
  @override
  Stream<List<MedicalAreaModel>> watchAreas(String uid) {
    areaReads++;
    if (catalogError != null) return Stream.error(catalogError!);
    return Stream.value(
      hasCatalog
          ? [MedicalAreaModel(id: 'a', name: areaName, code: 'A', order: 1)]
          : [],
    );
  }

  @override
  Stream<List<TopicModel>> watchTopics(String uid, String areaId) {
    topicReads++;
    return Stream.value(
      hasCatalog
          ? [
              const TopicModel(
                id: 't',
                areaId: 'a',
                title: 'Tema de prueba',
                order: 1,
              ),
            ]
          : [],
    );
  }

  @override
  Stream<List<QuizModel>> watchQuizzes(
    String uid,
    String areaId,
    String topicId,
  ) {
    quizReads++;
    return Stream.value(
      hasCatalog
          ? [
              const QuizModel(
                id: 'q',
                areaId: 'a',
                topicId: 't',
                question: 'Pregunta de prueba',
                options: ['Opción de prueba'],
                correctIndex: 0,
                rationale: '',
                sourceBook: '',
              ),
            ]
          : [],
    );
  }

  void changeUser(String? uid) {
    user = uid == null ? null : HistoryTestUser(uid);
    sessions.add(user);
  }

  Future<void> close() async {
    await sessions.close();
    for (final source in histories.values) {
      await source.close();
    }
  }
}

AcademicHistoryEntry entry({
  String id = 'private-record',
  DateTime? date,
  bool dated = true,
}) => AcademicHistoryEntry(
  id: id,
  areaId: 'a',
  topicId: 't',
  quizId: 'q',
  attemptNumber: 2,
  answeredAt: dated ? date ?? DateTime(2026, 10, 11, 12, 30) : null,
  isCorrect: true,
  earnedStars: 2,
  maxStars: 2,
  selectedOptionIndex: 0,
);
Widget historyScreen(
  HistoryScreenRepository repo,
  FakeConnectivity connection, {
  String? entryId,
  String? expectedUid,
  TextScaler? scaler,
}) => MaterialApp(
  theme: AppTheme.lightTheme,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: scaler ?? TextScaler.noScaling),
    child: child!,
  ),
  home: AcademicHistoryScreen(
    repository: repo,
    connectivity: connection,
    entryId: entryId,
    expectedUid: expectedUid,
  ),
);
Future<void> historyFrames(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
  await tester.pump();
}
