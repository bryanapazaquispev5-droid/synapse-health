import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/theme/app_theme.dart';
import 'package:synapse_health/core/widgets/states/app_async_content.dart';
import 'package:synapse_health/features/cheatsheets/model/topic_model.dart';
import 'package:synapse_health/features/personal_progress/model/progress_summary.dart';
import 'package:synapse_health/features/personal_progress/utils/progress_statistics.dart';
import 'package:synapse_health/features/personal_progress/ui/widgets/progress_evolution_section.dart';
import '../../core/widgets/fixtures/async_content_fixture.dart';
import 'personal_progress_widget_fixture.dart';

Widget evolution(List<TopicEvolution> series, Stream<List<TopicModel>> Function(String) topics,
    FakeConnectivity connection) => MaterialApp(theme: AppTheme.lightTheme,
  home: Scaffold(body: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(18),
    child: ProgressEvolutionSection(series: series, areaNames: const {'a': 'Área de prueba'},
      topicsStreamForArea: topics, connectivity: connection)))));

void main() {
  late FakeConnectivity connection;
  setUp(() { connection = FakeConnectivity(); });
  tearDown(() => connection.changes.close());

  testWidgets('insufficient dated history does not request metadata or invent a chart', (tester) async {
    var reads = 0;
    await tester.pumpWidget(evolution([], (_) { reads++; return Stream.value([]); }, connection));
    await frames(tester);
    expect(find.text('Todavía no hay evolución disponible'), findsOneWidget);
    expect(reads, 0);
  });

  testWidgets('two real attempts show their separate accuracy with topic name', (tester) async {
    final series = calculateProgress({'t': recordedProgress(history: true)}).evolution;
    await tester.pumpWidget(evolution(series, (_) => Stream.value([
      const TopicModel(id: 't', areaId: 'a', title: 'Tema de prueba', order: 1)]), connection));
    await frames(tester); await frames(tester);
    expect(find.text('Tema de prueba'), findsOneWidget);
    expect(find.text('Intento 1 · 0.0 %'), findsOneWidget);
    expect(find.text('Intento 2 · 100.0 %'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('multiple topics in an area share one metadata subscription', (tester) async {
    final original = calculateProgress({'t': recordedProgress(history: true)}).evolution.single;
    final series = [original, TopicEvolution(areaId: 'a', topicId: 'other', points: original.points)];
    var reads = 0;
    Stream<List<TopicModel>> topics(String _) { reads++; return Stream.value([]); }
    await tester.pumpWidget(evolution(series, topics, connection)); await frames(tester);
    await tester.pumpWidget(evolution(series, topics, connection)); await frames(tester);
    expect(reads, 1);
  });

  testWidgets('removed topic uses availability message instead of an invented medical name', (tester) async {
    final series = calculateProgress({'t': recordedProgress(history: true)}).evolution;
    await tester.pumpWidget(evolution(series, (_) => Stream.value([]), connection)); await frames(tester);
    expect(find.text('Tema no disponible'), findsOneWidget);
  });

  testWidgets('metadata failures remain errors without hiding the absence as empty history', (tester) async {
    final series = calculateProgress({'t': recordedProgress(history: true)}).evolution;
    await tester.pumpWidget(evolution(series, (_) => Stream.error(FirebaseException(
      plugin: 'cloud_firestore', code: 'unavailable', message: 'internal query')), connection));
    await frames(tester); await frames(tester);
    expect(find.byType(AppErrorState), findsOneWidget);
    expect(find.text('Todavía no hay evolución disponible'), findsNothing);
    expect(find.textContaining('internal query'), findsNothing);
  });
}
