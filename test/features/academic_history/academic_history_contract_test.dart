import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/features/academic_history/utils/academic_history_builder.dart';
import 'package:synapse_health/features/quizzes/model/quiz_topic_progress_model.dart';

void main() {
  test(
    'Flutter and Lambda share canonical IDs and retained history DTO contract',
    () {
      final fixture = jsonDecode(
        File('test/fixtures/history_contract.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      final progress = QuizTopicProgressModel.fromMap(
        fixture['progress'] as Map<String, dynamic>,
      );
      expect(
        buildAcademicHistory({'topic-contract': progress})
            .map((entry) => entry.toJson())
            .toList(),
        fixture['expected'],
      );
    },
  );
}
