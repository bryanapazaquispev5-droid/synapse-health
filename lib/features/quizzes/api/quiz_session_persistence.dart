import 'quiz_progress_service.dart';
import '../model/quiz_model.dart';
import '../../auth_login/model/trial_mode_session.dart';

/// Display calculations never authorize scores; raw responses go to the server.
class QuizSessionPersistence {
  final _progress = QuizProgressService();
  Map<String, dynamic>? answer;

  Future<void> record(
    QuizModel quiz, {
    required bool isCorrect,
    required int earnedStars,
    required int maxStars,
    required int totalMaxStars,
    int? selectedOptionIndex,
  }) => TrialModeSession.isActive
      ? Future<void>.value()
      : _progress.recordQuestionAnswer(
          areaId: quiz.areaId,
          topicId: quiz.topicId,
          quizId: quiz.id,
          isCorrect: isCorrect,
          earnedStars: earnedStars,
          maxStars: maxStars,
          topicTotalMaxStars: totalMaxStars,
          selectedOptionIndex: selectedOptionIndex,
          answer: answer,
        );
}
