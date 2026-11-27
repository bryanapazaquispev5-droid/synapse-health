import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../model/leaderboard_user_model.dart';
import '../../utils/time_formatter_helper.dart';

class LeaderboardUserTile extends StatelessWidget {
  const LeaderboardUserTile({
    super.key,
    required this.user,
    this.isCurrentUser = false,
    this.podiumPosition,
    this.showDivider = false,
  });

  final LeaderboardUserModel user;
  final bool isCurrentUser;
  final int? podiumPosition;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final accent = switch (podiumPosition) {
      1 => const Color(0xFF805500),
      2 => const Color(0xFF4A5969),
      3 => const Color(0xFF844C30),
      _ => AppColors.primaryDark,
    };
    final rankFill = switch (podiumPosition) {
      1 => const Color(0xFFFFF0CA),
      2 => const Color(0xFFE9EEF4),
      3 => const Color(0xFFF8E8DF),
      _ => Colors.transparent,
    };
    final score = _Score(user: user);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isCurrentUser
            ? const Color(0xFFE7F1FF)
            : podiumPosition == 1
            ? const Color(0xFFFFFCF4)
            : AppColors.surface,
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.border))
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stacked =
                constraints.maxWidth < 245 ||
                MediaQuery.textScalerOf(context).scale(14) > 20;
            return Row(
              children: [
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 34,
                    minHeight: 32,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: rankFill,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    podiumPosition?.toString() ?? '#${user.rank ?? '-'}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                    semanticsLabel: user.rank == null
                        ? null
                        : 'Position ${user.rank}',
                  ),
                ),
                const SizedBox(width: 8),
                LeaderboardAvatar(user: user),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (isCurrentUser)
                        const Text(
                          'Tú',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF0056B3),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      if (user.career.isNotEmpty)
                        Text(
                          user.career,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      if (stacked) ...[const SizedBox(height: 5), score],
                    ],
                  ),
                ),
                if (!stacked) ...[
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * .32,
                    ),
                    child: score,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Score extends StatelessWidget {
  const _Score({required this.user});
  final LeaderboardUserModel user;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.star_fill,
            size: 12,
            color: Color(0xFF805500),
          ),
          const SizedBox(width: 4),
          Text(
            '${user.totalStars}',
            semanticsLabel: '${user.totalStars} estrellas',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
        ],
      ),
      Text(
        TimeFormatterHelper.formatPace(user.averageTimeSeconds),
        style: const TextStyle(fontSize: 11, color: AppColors.primaryDark),
      ),
    ],
  );
}

class LeaderboardAvatar extends StatelessWidget {
  final double radius;
  const LeaderboardAvatar({super.key, required this.user, this.radius = 16});
  final LeaderboardUserModel user;

  @override
  Widget build(BuildContext context) {
    final url = user.photoUrl;
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.secondaryBackground,
      foregroundImage: url != null && url.isNotEmpty ? NetworkImage(url) : null,
      onForegroundImageError: url != null && url.isNotEmpty ? (_, _) {} : null,
      backgroundImage: AssetImage(
        user.gender.toLowerCase() == 'mujer'
            ? 'assets/images/user_girl.gif'
            : 'assets/images/user_boy.gif',
      ),
    );
  }
}
