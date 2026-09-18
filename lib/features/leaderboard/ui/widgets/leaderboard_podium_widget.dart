// Bloque: Podio olímpico para los 3 mejores estudiantes del Leaderboard
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../model/leaderboard_user_model.dart';
import '../../utils/time_formatter_helper.dart';

// Bloque: Componente principal de Podio Olímpico
class LeaderboardPodiumWidget extends StatelessWidget {
  final List<LeaderboardUserModel> topUsers;

  const LeaderboardPodiumWidget({super.key, required this.topUsers});

  @override
  Widget build(BuildContext context) {
    final first = topUsers.isNotEmpty ? topUsers[0] : null;
    final second = topUsers.length > 1 ? topUsers[1] : null;
    final third = topUsers.length > 2 ? topUsers[2] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _buildPodiumStep(user: second, rank: 2, height: 85, color: const Color(0xFFC0C0C0), badge: '🥈')),
          const SizedBox(width: 8),
          Expanded(child: _buildPodiumStep(user: first, rank: 1, height: 115, color: const Color(0xFFFFD700), badge: '🥇', isCenter: true)),
          const SizedBox(width: 8),
          Expanded(child: _buildPodiumStep(user: third, rank: 3, height: 65, color: const Color(0xFFCD7F32), badge: '🥉')),
        ],
      ),
    );
  }

  // Bloque: Renderizado de columna individual del podio
  Widget _buildPodiumStep({
    required LeaderboardUserModel? user,
    required int rank,
    required double height,
    required Color color,
    required String badge,
    bool isCenter = false,
  }) {
    final avatarRadius = isCenter ? 32.0 : 25.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isCenter)
          const Padding(
            padding: EdgeInsets.only(bottom: 2),
            child: Icon(CupertinoIcons.sparkles, color: Color(0xFFFFD700), size: 16),
          ),
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: isCenter ? 2.5 : 2.0),
              ),
              child: CircleAvatar(
                radius: avatarRadius,
                backgroundColor: AppColors.secondaryBackground,
                backgroundImage: _avatarProvider(user),
              ),
            ),
            Positioned(
              bottom: -4,
              right: -4,
              child: Text(badge, style: TextStyle(fontSize: isCenter ? 16 : 13)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          user?.displayName ?? 'Disponible',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: '.SF Pro Text',
            fontSize: isCenter ? 13 : 11,
            fontWeight: FontWeight.w700,
            color: user != null ? AppColors.primary : AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          user?.career ?? '-',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: '.SF Pro Text', fontSize: 10, color: AppColors.textMuted),
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.star_fill, color: Color(0xFFFFB800), size: 11),
            const SizedBox(width: 2),
            Text(
              '${user?.totalStars ?? 0}',
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: user != null ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
        Text(
          TimeFormatterHelper.formatPace(user?.averageTimeSeconds ?? 0),
          style: const TextStyle(fontFamily: '.SF Pro Text', fontSize: 9, color: AppColors.textMuted),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0.06)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            '$rank',
            style: TextStyle(
              fontFamily: '.SF Pro Display',
              fontSize: isCenter ? 32 : 24,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  // Bloque: Proveedor de imagen para avatar con fallback por género
  ImageProvider _avatarProvider(LeaderboardUserModel? user) {
    if (user?.photoUrl != null && user!.photoUrl!.isNotEmpty) {
      return NetworkImage(user.photoUrl!);
    }
    final isGirl = (user?.gender ?? '').toLowerCase() == 'mujer';
    return AssetImage(isGirl ? 'assets/images/user_girl.gif' : 'assets/images/user_boy.gif');
  }
}
