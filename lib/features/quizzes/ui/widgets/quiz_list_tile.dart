// Bloque: Componente interactivo para mostrar cada pregunta de quiz en la lista del tema
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../model/quiz_model.dart';
import '../../model/quiz_question_progress_model.dart';
import '../quiz_session_screen.dart';

// Bloque: Componente visual modular [QuizListTile]
class QuizListTile extends StatelessWidget {
  final QuizModel quiz;
  final int index;
  final List<QuizModel> allQuizzes;
  final String areaTitle;
  final QuizQuestionProgressModel? questionProgress;
  final bool isAttemptStarted;

  const QuizListTile({
    super.key,
    required this.quiz,
    required this.index,
    required this.allQuizzes,
    required this.areaTitle,
    this.questionProgress,
    this.isAttemptStarted = true,
  });

  @override
  Widget build(BuildContext context) {
    // Bloque: Verificación de estado de respuesta y bloqueo
    final bool isLocked = questionProgress?.isAnswered == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Bloque: Validación si el intento de práctica no ha comenzado
            if (!isAttemptStarted) {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    "Pulsa 'Comenzar Examen de Práctica' para iniciar el quiz del tema.",
                    style: TextStyle(fontWeight: FontWeight.w600, fontFamily: '.SF Pro Text'),
                  ),
                  backgroundColor: AppColors.accent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 3),
                ),
              );
              return;
            }

            // Bloque: Acción al pulsar pregunta bloqueada o completada
            if (isLocked) {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    "Pregunta completada en este intento. Pulsa 'Reintentar tema' para responderla nuevamente.",
                    style: TextStyle(fontWeight: FontWeight.w600, fontFamily: '.SF Pro Text'),
                  ),
                  backgroundColor: AppColors.accent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 3),
                ),
              );
              return;
            }

            Navigator.push(
              context,
              AppPageRoute(
                child: QuizSessionScreen(
                  quizzes: allQuizzes,
                  areaTitle: areaTitle,
                  initialIndex: index - 1,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLocked ? const Color(0xFFF9F9FB) : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isLocked ? const Color(0xFFE5E5EA) : AppColors.border,
                width: 0.6,
              ),
              boxShadow: const [
                BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bloque: Fila superior con tipo de quiz, estado de bloqueo y estrellas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: quiz.typeBackgroundColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            quiz.typeLabel.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: quiz.typeColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        if (isLocked) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFFDE68A), width: 0.6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('⭐', style: TextStyle(fontSize: 10)),
                                const SizedBox(width: 3),
                                Text(
                                  '${questionProgress!.earnedStars}/${questionProgress!.maxStars}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLocked) ...[
                          const Icon(CupertinoIcons.lock_fill, size: 13, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          'Pregunta #$index',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Bloque: Enunciado de la pregunta
                Text(
                  quiz.cleanQuestionPrompt,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: isLocked ? AppColors.textMuted : AppColors.primary,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Bloque: Referencia bibliográfica si existe
                if (quiz.sourceBook.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Fuente: ${quiz.sourceBook}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
