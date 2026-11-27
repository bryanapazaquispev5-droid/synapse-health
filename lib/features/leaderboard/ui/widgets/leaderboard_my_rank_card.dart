import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_theme.dart';
import '../../model/leaderboard_user_model.dart';
import '../../utils/time_formatter_helper.dart';

class LeaderboardMyRankCard extends StatelessWidget {
  const LeaderboardMyRankCard({super.key, this.currentUser});

  final LeaderboardUserModel? currentUser;

  static String rankLabel(LeaderboardUserModel? user) {
    final rank = user?.rank;
    return rank != null && (user?.completedQuizzesCount ?? 0) > 0
        ? '#$rank'
        : 'Sin clasificar';
  }

  @override
  Widget build(BuildContext context) {
    final rank = rankLabel(currentUser);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFDDEBFE),
        border: Border.all(color: const Color(0xFFCEDFF7)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        spacing: 13,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF0F6FF),
            ),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                CupertinoIcons.rosette,
                color: Color(0xFF0056B3),
                size: 19,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tu posición global',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Text(
                rank,
                style: const TextStyle(
                  fontSize: 30,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0056B3),
                ),
              ),
            ],
          ),
          if (currentUser case final user? when rank != 'Sin clasificar')
            Wrap(
              spacing: 12,
              runSpacing: 5,
              children: [
                _RankMetric(
                  icon: CupertinoIcons.star_fill,
                  label: '${user.totalStars} estrellas',
                ),
                _RankMetric(
                  icon: CupertinoIcons.stopwatch,
                  label: TimeFormatterHelper.formatPace(
                    user.averageTimeSeconds,
                  ),
                ),
              ],
            )
          else
            const Text(
              'Completa quizzes para obtener una posición.',
              style: TextStyle(fontSize: 12, color: AppColors.primaryDark),
            ),
        ],
      ),
    );
  }
}

class _RankMetric extends StatelessWidget {
  const _RankMetric({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 5,
    children: [
      Icon(icon, size: 14, color: const Color(0xFF0056B3)),
      Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    ],
  );
}
