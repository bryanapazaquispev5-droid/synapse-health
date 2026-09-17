// ============================================================================
// Archivo: quiz_session_screen.dart
// Propósito: Controlador de estado y presentador de la sesion interactiva de evaluacion o examen medico.
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../model/quiz_model.dart';
import 'widgets/interactive_matching_widget.dart';
import 'widgets/interactive_ordering_widget.dart';
import 'widgets/quiz_option_card.dart';
import 'widgets/quiz_prompt_card.dart';
import 'widgets/quiz_rationale_card.dart';
import 'widgets/quiz_result_view.dart';
import 'widgets/quiz_session_bottom_bar.dart';
import 'widgets/quiz_session_header.dart';

// Pantalla de interfaz de usuario [QuizSessionScreen]
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

// Estado reactivo y control de ciclo de vida para [QuizSessionScreen]
class _QuizSessionScreenState extends State<QuizSessionScreen> {
  late int _currentIndex;
  int? _selectedOptionIndex;
  bool? _isMatchingCorrect;
  bool? _isOrderingCorrect;
  bool _isAnswered = false;
  int _score = 0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = (widget.initialIndex >= 0 && widget.initialIndex < widget.quizzes.length)
        ? widget.initialIndex
        : 0;
  }

  void _handleOptionSelected(int index) {
    if (_isAnswered) return;

    final currentQuiz = widget.quizzes[_currentIndex];
    final bool isCorrect = index == currentQuiz.correctIndex;

    setState(() {
      _selectedOptionIndex = index;
      _isAnswered = true;
      if (isCorrect) {
        _score++;
      }
    });
  }

  void _handleMatchingCompleted(bool isCorrect) {
    setState(() {
      _isAnswered = true;
      _isMatchingCorrect = isCorrect;
      if (isCorrect) {
        _score++;
      }
    });
  }

  void _handleOrderingCompleted(bool isCorrect) {
    setState(() {
      _isAnswered = true;
      _isOrderingCorrect = isCorrect;
      if (isCorrect) {
        _score++;
      }
    });
  }

  void _handleNextQuestion() {
    if (_currentIndex < widget.quizzes.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
        _isMatchingCorrect = null;
        _isOrderingCorrect = null;
        _isAnswered = false;
      });
    } else {
      setState(() {
        _isCompleted = true;
      });
    }
  }

  void _restartQuizSession() {
    setState(() {
      _currentIndex = 0;
      _selectedOptionIndex = null;
      _isMatchingCorrect = null;
      _isOrderingCorrect = null;
      _isAnswered = false;
      _score = 0;
      _isCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quizzes.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: CupertinoNavigationBar(
          middle: Text(widget.areaTitle),
        ),
        body: const Center(
          child: Text('No hay preguntas disponibles en este momento.'),
        ),
      );
    }

    if (_isCompleted) {
      return QuizResultView(
        score: _score,
        totalQuestions: widget.quizzes.length,
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
              onExit: () => Navigator.pop(context),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
                children: [
                  QuizPromptCard(quiz: quiz),
                  const SizedBox(height: 18),
                  if (quiz.type == 'matching') ...[
                    InteractiveMatchingWidget(
                      key: ValueKey('${quiz.id}_$_currentIndex'),
                      quiz: quiz,
                      isAnswered: _isAnswered,
                      onCompleted: _handleMatchingCompleted,
                    ),
                  ] else if (quiz.type == 'ordering') ...[
                    InteractiveOrderingWidget(
                      key: ValueKey('${quiz.id}_$_currentIndex'),
                      quiz: quiz,
                      isAnswered: _isAnswered,
                      onCompleted: _handleOrderingCompleted,
                    ),
                  ] else ...[
                    ...List.generate(quiz.options.length, (index) {
                      final optionText = quiz.options[index];
                      final optionLetter = String.fromCharCode(65 + index);
                      return QuizOptionCard(
                        index: index,
                        letter: optionLetter,
                        text: optionText,
                        correctIndex: quiz.correctIndex,
                        selectedOptionIndex: _selectedOptionIndex,
                        isAnswered: _isAnswered,
                        onSelected: _handleOptionSelected,
                      );
                    }),
                  ],
                  if (_isAnswered) ...[
                    const SizedBox(height: 16),
                    QuizRationaleCard(
                      quiz: quiz,
                      isMatchingCorrect: _isMatchingCorrect,
                      isOrderingCorrect: _isOrderingCorrect,
                      selectedOptionIndex: _selectedOptionIndex,
                    ),
                  ],
                ],
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
