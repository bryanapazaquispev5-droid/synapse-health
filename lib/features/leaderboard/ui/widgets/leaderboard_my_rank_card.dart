// Bloque: Tarjeta de posición y progreso del usuario actual en el Leaderboard
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_theme.dart';
import '../../model/leaderboard_user_model.dart';
import '../../utils/time_formatter_helper.dart';

// Bloque: Tarjeta destacada con el rango del usuario autenticado
class LeaderboardMyRankCard extends StatelessWidget {
  final LeaderboardUserModel? currentUser;
  final User? fallbackUser;

  const LeaderboardMyRankCard({
    super.key,
    this.currentUser,
    this.fallbackUser,
  });

  @override
  Widget build(BuildContext context) {
    final rank = currentUser?.rank;
    final hasRank = rank != null && (currentUser?.completedQuizzesCount ?? 0) > 0;

    final String motivation;
    if (!hasRank) {
      motivation = '¡Completa quizzes! ⚡';
    } else if (rank <= 3) {
      motivation = '¡En el Podio! 🏆';
    } else if (rank <= 10) {
      motivation = '¡En el Top 10! 🔥';
    } else {
      motivation = '¡A por el podio! 🚀';
    }

    final stars = currentUser?.totalStars ?? 0;
    final pace = TimeFormatterHelper.formatPace(currentUser?.averageTimeSeconds ?? 0);
    final rankText = hasRank ? '#$rank' : 'Sin clasificar';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: const Icon(CupertinoIcons.rosette, color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tu Posición Global', style: TextStyle(fontFamily: '.SF Pro Text', fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                    Text(rankText, style: const TextStyle(fontFamily: '.SF Pro Text', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(motivation, style: const TextStyle(fontFamily: '.SF Pro Text', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accent)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 0.5, thickness: 0.5, color: AppColors.border),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric(CupertinoIcons.star_fill, const Color(0xFFFFB800), '$stars Estrellas'),
              Container(width: 1, height: 14, color: AppColors.border),
              _buildMetric(CupertinoIcons.stopwatch_fill, AppColors.systemTeal, pace),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(IconData icon, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontFamily: '.SF Pro Text', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
      ],
    );
  }
}
