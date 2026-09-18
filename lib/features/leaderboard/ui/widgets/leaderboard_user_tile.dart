// Bloque: Tile de usuario para posiciones 4+ en el Leaderboard
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../model/leaderboard_user_model.dart';
import '../../utils/time_formatter_helper.dart';

// Bloque: Componente de fila individual de usuario en el ranking
class LeaderboardUserTile extends StatelessWidget {
  final LeaderboardUserModel user;
  final bool isCurrentUser;

  const LeaderboardUserTile({
    super.key,
    required this.user,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatarImg = (user.photoUrl != null && user.photoUrl!.isNotEmpty)
        ? NetworkImage(user.photoUrl!) as ImageProvider
        : AssetImage(user.gender.toLowerCase() == 'mujer' ? 'assets/images/user_girl.gif' : 'assets/images/user_boy.gif');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrentUser ? AppColors.accent.withValues(alpha: 0.08) : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrentUser ? AppColors.accent.withValues(alpha: 0.4) : AppColors.border,
          width: isCurrentUser ? 1.5 : 0.8,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#${user.rank ?? '-'}',
              style: TextStyle(
                fontFamily: '.SF Pro Text', fontWeight: FontWeight.w700, fontSize: 14,
                color: isCurrentUser ? AppColors.accent : AppColors.textMuted,
              ),
            ),
          ),
          CircleAvatar(radius: 19, backgroundColor: AppColors.secondaryBackground, backgroundImage: avatarImg),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: '.SF Pro Text', fontWeight: FontWeight.w600, fontSize: 14,
                          color: isCurrentUser ? AppColors.accent : AppColors.primary,
                        ),
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(8)),
                        child: const Text('Tú', style: TextStyle(fontFamily: '.SF Pro Text', fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  user.career,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: '.SF Pro Text', fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(CupertinoIcons.star_fill, color: Color(0xFFFFB800), size: 13),
                  const SizedBox(width: 3),
                  Text('${user.totalStars}', style: const TextStyle(fontFamily: '.SF Pro Text', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 2),
              Text(TimeFormatterHelper.formatPace(user.averageTimeSeconds), style: const TextStyle(fontFamily: '.SF Pro Text', fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
