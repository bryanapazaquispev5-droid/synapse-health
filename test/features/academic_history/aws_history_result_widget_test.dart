import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/theme/app_theme.dart';
import 'package:synapse_health/features/academic_history/model/academic_history_entry.dart';
import 'package:synapse_health/features/academic_history/ui/widgets/history_catalog.dart';
import 'package:synapse_health/features/academic_history/ui/widgets/history_result.dart';

void main() {
  testWidgets('existing result component renders measured AWS fields', (
    tester,
  ) async {
    final entry = AcademicHistoryEntry.fromJson({
      'id': 'attempt',
      'areaId': 'area',
      'topicId': 'topic',
      'quizId': 'quiz',
      'attemptNumber': 1,
      'answeredAt': '2026-01-01T00:00:10Z',
      'isCorrect': true,
      'earnedStars': 1,
      'maxStars': 1,
      'selectedOptionIndex': null,
      'durationSeconds': 10,
      'score': 1,
      'status': 'submitted',
      'quizTitle': 'Local fixture title',
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: HistoryResult(entry: entry, labels: HistoryLabels()),
        ),
      ),
    );
    expect(find.text('Local fixture title'), findsOneWidget);
    expect(find.text('10 s'), findsOneWidget);
    expect(find.text('Puntuación'), findsOneWidget);
    expect(find.text('Registrado'), findsOneWidget);
    expect(find.text('No registrado'), findsNothing);
    expect(
      find.text('Se conservan el intento actual y hasta tres anteriores.'),
      findsNothing,
    );
    final legacy = AcademicHistoryEntry.fromJson(
      entry.toJson()
        ..remove('status')
        ..remove('score'),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: HistoryResult(entry: legacy, labels: HistoryLabels()),
        ),
      ),
    );
    expect(
      find.text('Se conservan el intento actual y hasta tres anteriores.'),
      findsOneWidget,
    );
  });
}
