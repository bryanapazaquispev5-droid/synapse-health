import 'dart:convert';

import '../../quizzes/model/quiz_attempt_model.dart';
import '../../quizzes/model/quiz_topic_progress_model.dart';
import '../model/academic_history_entry.dart';

/// A canonical identifier shared with the backend; it is not authorization.
String canonicalHistoryEntryId(
  String areaId,
  String topicId,
  int attemptNumber,
  String quizId,
) => base64Url
    .encode(utf8.encode(jsonEncode([areaId, topicId, attemptNumber, quizId])))
    .replaceAll('=', '');

List<AcademicHistoryEntry> buildAcademicHistory(
  Map<String, QuizTopicProgressModel> progress,
) {
  final entries = <String, AcademicHistoryEntry>{};
  for (final topic in progress.values) {
    final retained =
        topic.history.length > QuizTopicProgressModel.maxHistoryEntries
        ? topic.history.sublist(
            topic.history.length - QuizTopicProgressModel.maxHistoryEntries,
          )
        : topic.history;
    final attempts = <int, QuizAttemptModel>{
      for (final attempt in retained) attempt.attemptNumber: attempt,
      topic.activeAttempt.attemptNumber: topic.activeAttempt,
    };
    for (final attempt in attempts.values) {
      for (final answerEntry in attempt.questionAnswers.entries) {
        final answer = answerEntry.value;
        if (!answer.isAnswered || answerEntry.key.isEmpty) continue;
        final id = canonicalHistoryEntryId(
          topic.areaId,
          topic.topicId,
          attempt.attemptNumber,
          answerEntry.key,
        );
        entries[id] = AcademicHistoryEntry(
          id: id,
          areaId: topic.areaId,
          topicId: topic.topicId,
          quizId: answerEntry.key,
          attemptNumber: attempt.attemptNumber,
          answeredAt: answer.answeredAt,
          isCorrect: answer.isCorrect,
          earnedStars: answer.earnedStars,
          maxStars: answer.maxStars,
          selectedOptionIndex: answer.selectedOptionIndex,
        );
      }
    }
  }
  return entries.values.toList()..sort(_compareEntries);
}

int _compareEntries(AcademicHistoryEntry left, AcademicHistoryEntry right) {
  final leftDate = left.answeredAt;
  final rightDate = right.answeredAt;
  if (leftDate == null && rightDate != null) return 1;
  if (leftDate != null && rightDate == null) return -1;
  if (leftDate != null && rightDate != null) {
    final chronological = rightDate.compareTo(leftDate);
    if (chronological != 0) return chronological;
  }
  return left.id.compareTo(right.id);
}

AcademicHistoryEntry? findAcademicHistoryEntry(
  List<AcademicHistoryEntry> entries,
  String id,
) {
  for (final entry in entries) {
    if (entry.id == id) return entry;
  }
  return null;
}
