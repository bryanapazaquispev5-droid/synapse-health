import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../leaderboard/api/leaderboard_service.dart';
import '../api/quiz_progress_service.dart';
import '../model/quiz_model.dart';
import '../utils/quiz_scoring_helper.dart';
import 'widgets/quiz_question_body.dart';
import 'widgets/quiz_result_view.dart';
import 'widgets/quiz_session_bottom_bar.dart';
import 'widgets/quiz_session_header.dart';

// Bloque: Pantalla principal [QuizSessionScreen]
class QuizSessionScreen extends StatefulWidget {
  final List<QuizModel> quizzes;
  final String areaTitle;
  final int initialIndex;

  const QuizSessionScreen({
    super.key,
    required this.quizzes,
    this.areaTitle = 'Anatomía Humana',
    this.initialIndex = 0,
  });

  @override
  State<QuizSessionScreen> createState() => _QuizSessionScreenState();
}

class _QuizSessionScreenState extends State<QuizSessionScreen> {
  late int _currentIndex, _totalMaxStars;
  int? _selectedOptionIndex;
  bool? _isMatchingCorrect, _isOrderingCorrect;
  bool _isAnswered = false, _isCompleted = false;
  int _score = 0, _totalEarnedStars = 0, _currentEarnedStars = 0, _currentMaxStars = 1;
  int _currentQuestionSeconds = 0, _elapsedSessionSeconds = 0;
  late DateTime _sessionStartTime, _questionStartTime;
  Timer? _tickerTimer;

  @override
  void initState() {
    super.initState();
    _currentIndex = (widget.initialIndex >= 0 && widget.initialIndex < widget.quizzes.length) ? widget.initialIndex : 0;
    _totalMaxStars = QuizScoringHelper.calculateTotalMaxStars(widget.quizzes);
    _sessionStartTime = DateTime.now();
    _questionStartTime = DateTime.now();
    _startTimer();
  }

  void _startTimer() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_isCompleted) {
        setState(() => _elapsedSessionSeconds = DateTime.now().difference(_sessionStartTime).inSeconds);
      }
    });
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }

  // Bloque: Helper común para reiniciar campos de la pregunta activa
  void _resetQuestionFields() {
    _selectedOptionIndex = null;
    _isMatchingCorrect = null;
    _isOrderingCorrect = null;
    _isAnswered = false;
    _currentEarnedStars = 0;
    _currentMaxStars = 1;
    _currentQuestionSeconds = 0;
    _questionStartTime = DateTime.now();
  }

  // Bloque: Registro en segundo plano del progreso en Firestore
  void _recordProgress({
    required bool isCorrect,
    required int earnedStars,
    required int maxStars,
    int? selectedOptionIndex,
  }) {
    final quiz = widget.quizzes[_currentIndex];
    QuizProgressService().recordQuestionAnswer(
      areaId: quiz.areaId,
      topicId: quiz.topicId,
      quizId: quiz.id,
      isCorrect: isCorrect,
      earnedStars: earnedStars,
      maxStars: maxStars,
      selectedOptionIndex: selectedOptionIndex,
      topicTotalMaxStars: _totalMaxStars,
    );
  }

  void _handleOptionSelected(int index) {
    if (_isAnswered) return;
    final currentQuiz = widget.quizzes[_currentIndex];
    final bool isCorrect = index == currentQuiz.correctIndex;
    final int spent = DateTime.now().difference(_questionStartTime).inSeconds;

    setState(() {
      _selectedOptionIndex = index;
      _isAnswered = true;
      _currentQuestionSeconds = spent;
      _currentMaxStars = 1;
      _currentEarnedStars = isCorrect ? 1 : 0;
      if (isCorrect) {
        _score++;
        _totalEarnedStars += 1;
      }
    });

    _recordProgress(isCorrect: isCorrect, earnedStars: isCorrect ? 1 : 0, maxStars: 1, selectedOptionIndex: index);
  }

  void _handleMatchingCompleted(bool isCorrect, int earnedStars, int maxStars) {
    final int spent = DateTime.now().difference(_questionStartTime).inSeconds;
    setState(() {
      _isAnswered = true;
      _isMatchingCorrect = isCorrect;
      _currentQuestionSeconds = spent;
      _currentMaxStars = maxStars;
      _currentEarnedStars = earnedStars;
      _totalEarnedStars += earnedStars;
      if (isCorrect) _score++;
    });

    _recordProgress(isCorrect: isCorrect, earnedStars: earnedStars, maxStars: maxStars);
  }

  void _handleOrderingCompleted(bool isCorrect, int earnedStars, int maxStars) {
    final int spent = DateTime.now().difference(_questionStartTime).inSeconds;
    setState(() {
      _isAnswered = true;
      _isOrderingCorrect = isCorrect;
      _currentQuestionSeconds = spent;
      _currentMaxStars = maxStars;
      _currentEarnedStars = earnedStars;
      _totalEarnedStars += earnedStars;
      if (isCorrect) _score++;
    });

    _recordProgress(isCorrect: isCorrect, earnedStars: earnedStars, maxStars: maxStars);
  }

  void _handleNextQuestion() {
    if (_currentIndex < widget.quizzes.length - 1) {
      setState(() { _currentIndex++; _resetQuestionFields(); });
    } else {
      _tickerTimer?.cancel();
      setState(() => _isCompleted = true);
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        LeaderboardService().recordCompletedQuiz(
          uid: uid,
          earnedStars: _totalEarnedStars,
          durationSeconds: _elapsedSessionSeconds,
        );
      }
    }
  }

  void _restartQuizSession() {
    setState(() {
      _currentIndex = 0; _score = 0; _totalEarnedStars = 0; _elapsedSessionSeconds = 0;
      _isCompleted = false; _sessionStartTime = DateTime.now();
      _resetQuestionFields();
    });
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quizzes.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: CupertinoNavigationBar(middle: Text(widget.areaTitle)),
        body: const Center(child: Text('No hay preguntas disponibles en este momento.')),
      );
    }

    if (_isCompleted) {
      return QuizResultView(
        score: _score,
        totalQuestions: widget.quizzes.length,
        earnedStars: _totalEarnedStars,
        totalMaxStars: _totalMaxStars,
        totalDurationSeconds: _elapsedSessionSeconds,
        areaTitle: widget.areaTitle,
        onRestart: _restartQuizSession,
        onExit: () => Navigator.pop(context),
      );
    }

    final quiz = widget.quizzes[_currentIndex];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            QuizSessionHeader(
              currentIndex: _currentIndex,
              totalQuestions: widget.quizzes.length,
              earnedStars: _totalEarnedStars,
              elapsedSeconds: _elapsedSessionSeconds,
              onExit: () => Navigator.pop(context),
            ),
            Expanded(
              child: QuizQuestionBody(
                quiz: quiz,
                currentIndex: _currentIndex,
                isAnswered: _isAnswered,
                selectedOptionIndex: _selectedOptionIndex,
                isMatchingCorrect: _isMatchingCorrect,
                isOrderingCorrect: _isOrderingCorrect,
                currentEarnedStars: _currentEarnedStars,
                currentMaxStars: _currentMaxStars,
                currentQuestionSeconds: _currentQuestionSeconds,
                onOptionSelected: _handleOptionSelected,
                onMatchingCompleted: _handleMatchingCompleted,
                onOrderingCompleted: _handleOrderingCompleted,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isAnswered
          ? QuizSessionBottomBar(
              hasNext: _currentIndex < widget.quizzes.length - 1,
              onNext: _handleNextQuestion,
            )
          : null,
    );
  }
}
