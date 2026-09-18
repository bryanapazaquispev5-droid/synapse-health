// Bloque: Tarjeta de resumen de intento, progreso y acción de reintento de tema
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../api/quiz_progress_service.dart';
import '../../model/quiz_topic_progress_model.dart';

// Bloque: Componente interactivo [QuizTopicRetryCard]
class QuizTopicRetryCard extends StatefulWidget {
  final QuizTopicProgressModel progress;
  final int totalQuizzes;
  final int totalMaxStars;
  final String areaId;
  final String topicId;

  const QuizTopicRetryCard({
    super.key,
    required this.progress,
    required this.totalQuizzes,
    required this.totalMaxStars,
    required this.areaId,
    required this.topicId,
  });

  @override
  State<QuizTopicRetryCard> createState() => _QuizTopicRetryCardState();
}

class _QuizTopicRetryCardState extends State<QuizTopicRetryCard> {
  bool _isRetrying = false;

  // Bloque: Diálogo de confirmación para reintentar el tema
  void _confirmRetry() {
    HapticFeedback.lightImpact();
    showCupertinoDialog<void>(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: const Text('¿Reintentar tema?'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Tu progreso actual de ${widget.progress.activeAttempt.totalEarnedStars} estrellas se guardará en tu historial (hasta 3 reintentos guardados en BD). Todas las preguntas se desbloquearán para volver a responderlas.',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancelar'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(dialogCtx);
              _executeRetry();
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  // Bloque: Ejecución asíncrona del reintento con servicio
  Future<void> _executeRetry() async {
    if (_isRetrying) return;
    setState(() => _isRetrying = true);
    HapticFeedback.mediumImpact();

    try {
      await QuizProgressService().retryTopic(
        areaId: widget.areaId,
        topicId: widget.topicId,
        totalMaxStars: widget.totalMaxStars,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(CupertinoIcons.arrow_counterclockwise_circle_fill, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Expanded(child: Text('Tema reiniciado. Todas las preguntas están desbloqueadas.', style: TextStyle(fontWeight: FontWeight.w600))),
              ],
            ),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No se pudo reintentar el tema en este momento.'),
            backgroundColor: AppColors.systemRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRetrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int answered = widget.progress.activeAttempt.answeredCount;
    final int total = widget.totalQuizzes > 0 ? widget.totalQuizzes : 1;
    final double ratio = (answered / total).clamp(0.0, 1.0);
    final int earned = widget.progress.activeAttempt.totalEarnedStars;
    final int maxStars = widget.totalMaxStars > 0
        ? widget.totalMaxStars
        : (widget.progress.activeAttempt.totalMaxStars > 0
            ? widget.progress.activeAttempt.totalMaxStars
            : widget.totalQuizzes);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Intento #${widget.progress.currentAttemptNumber}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent)),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  Text('$earned / $maxStars estrellas', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFD97706))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$answered / ${widget.totalQuizzes} completadas', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
              Text('${(ratio * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: const Color(0xFFE5E5EA),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              color: const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(10),
              onPressed: _isRetrying ? null : _confirmRetry,
              child: _isRetrying
                  ? const CupertinoActivityIndicator(radius: 8)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(CupertinoIcons.arrow_clockwise, size: 14, color: AppColors.accent),
                        SizedBox(width: 6),
                        Text('Reintentar tema', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accent)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
