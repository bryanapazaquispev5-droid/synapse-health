import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../model/quiz_model.dart';
import '../quiz_session_screen.dart';

class QuizListTile extends StatelessWidget {
  final QuizModel quiz;
  final int index;
  final List<QuizModel> allQuizzes;
  final String areaTitle;

  const QuizListTile({
    super.key,
    required this.quiz,
    required this.index,
    required this.allQuizzes,
    required this.areaTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
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
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 0.6),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                const SizedBox(height: 10),
                Text(
                  quiz.cleanQuestionPrompt,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
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
