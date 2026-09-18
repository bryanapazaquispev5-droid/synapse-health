// ============================================================================
// Archivo: quiz_question_body.dart
// Propósito: Componente ensamblador para el cuerpo de la pregunta interactiva (opciones, matching, ordering y rationale).
// ============================================================================

import 'package:flutter/material.dart';
import '../../model/quiz_model.dart';
import 'interactive_matching_widget.dart';
import 'interactive_ordering_widget.dart';
import 'quiz_option_card.dart';
import 'quiz_prompt_card.dart';
import 'quiz_rationale_card.dart';

// Componente visual modular [QuizQuestionBody]
class QuizQuestionBody extends StatelessWidget {
  final QuizModel quiz;
  final int currentIndex;
  final bool isAnswered;
  final int? selectedOptionIndex;
  final bool? isMatchingCorrect;
  final bool? isOrderingCorrect;
  final int currentEarnedStars;
  final int currentMaxStars;
  final int currentQuestionSeconds;
  final ValueChanged<int> onOptionSelected;
  final void Function(bool isCorrect, int earnedStars, int maxStars) onMatchingCompleted;
  final void Function(bool isCorrect, int earnedStars, int maxStars) onOrderingCompleted;

  const QuizQuestionBody({
    super.key,
    required this.quiz,
    required this.currentIndex,
    required this.isAnswered,
    required this.selectedOptionIndex,
    required this.isMatchingCorrect,
    required this.isOrderingCorrect,
    required this.currentEarnedStars,
    required this.currentMaxStars,
    required this.currentQuestionSeconds,
    required this.onOptionSelected,
    required this.onMatchingCompleted,
    required this.onOrderingCompleted,
  });

  // Renderizado reactivo del arbol de widgets
  // Bloque: Renderizado reactivo del árbol de widgets principal
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
      children: [
        QuizPromptCard(quiz: quiz),
        const SizedBox(height: 18),
        if (quiz.type == 'matching') ...[
          InteractiveMatchingWidget(
            key: ValueKey('${quiz.id}_$currentIndex'),
            quiz: quiz,
            isAnswered: isAnswered,
            onCompleted: onMatchingCompleted,
          ),
        ] else if (quiz.type == 'ordering') ...[
          InteractiveOrderingWidget(
            key: ValueKey('${quiz.id}_$currentIndex'),
            quiz: quiz,
            isAnswered: isAnswered,
            onCompleted: onOrderingCompleted,
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
              selectedOptionIndex: selectedOptionIndex,
              isAnswered: isAnswered,
              onSelected: onOptionSelected,
            );
          }),
        ],
        if (isAnswered) ...[
          const SizedBox(height: 16),
          QuizRationaleCard(
            quiz: quiz,
            isMatchingCorrect: isMatchingCorrect,
            isOrderingCorrect: isOrderingCorrect,
            selectedOptionIndex: selectedOptionIndex,
            earnedStars: currentEarnedStars,
            maxStars: currentMaxStars,
            elapsedSeconds: currentQuestionSeconds,
          ),
        ],
      ],
    );
  }
}
