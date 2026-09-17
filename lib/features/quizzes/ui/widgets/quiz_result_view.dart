// ============================================================================
// Archivo: quiz_result_view.dart
// Propósito: Componente interactivo [quiz_result_view] para la resolucion de preguntas de opcion multiple, relacion o secuencia.
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// Pantalla de interfaz de usuario [QuizResultView]
class QuizResultView extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final String areaTitle;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const QuizResultView({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.areaTitle,
    required this.onRestart,
    required this.onExit,
  });

  // Renderizado reactivo del arbol de widgets
  // Bloque: Renderizado reactivo del árbol de widgets principal
  @override
  Widget build(BuildContext context) {
    final double percentage = totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;
    final bool hasPassed = percentage >= 60;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: hasPassed ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      hasPassed ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.exclamationmark_circle_fill,
                      size: 50,
                      color: hasPassed ? AppColors.systemGreen : AppColors.systemRed,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  hasPassed ? '¡Excelente Desempeño!' : 'Buen Intento de Repaso',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sesión de Quizzes completada para $areaTitle',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$score / $totalQuestions',
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: AppColors.accent,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${percentage.toStringAsFixed(0)}% de precisión médica',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CupertinoButton.filled(
                    borderRadius: BorderRadius.circular(16),
                    onPressed: onRestart,
                    child: const Text(
                      'Repetir Quiz',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CupertinoButton(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    onPressed: onExit,
                    child: const Text(
                      'Volver al Menú Principal',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
