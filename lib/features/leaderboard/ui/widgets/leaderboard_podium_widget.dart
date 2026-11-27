import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../model/leaderboard_user_model.dart';
import '../../utils/time_formatter_helper.dart';
import 'leaderboard_entrance.dart';
import 'leaderboard_user_tile.dart';

class LeaderboardPodiumWidget extends StatelessWidget {
  const LeaderboardPodiumWidget({
    super.key,
    required this.topUsers,
    this.currentUserId,
  });

  final List<LeaderboardUserModel> topUsers;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact =
          constraints.maxWidth < 275 ||
          MediaQuery.textScalerOf(context).scale(13) > 17;
      if (topUsers.length < 3 || compact) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            children: [
              for (var index = 0; index < topUsers.length; index++)
                LeaderboardEntrance(
                  key: ValueKey(topUsers[index].userId),
                  order: index,
                  child: LeaderboardUserTile(
                    user: topUsers[index],
                    isCurrentUser: topUsers[index].userId == currentUserId,
                    podiumPosition: index + 1,
                    showDivider: index < topUsers.length - 1,
                  ),
                ),
            ],
          ),
        );
      }

      return DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFECF3FC),
          border: Border.all(color: const Color(0xFFD9E6F7)),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(9, 13, 9, 9),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final index in [1, 0, 2])
                Expanded(
                  child: LeaderboardEntrance(
                    key: ValueKey(topUsers[index].userId),
                    order: index,
                    child: _PodiumPlace(
                      user: topUsers[index],
                      position: index + 1,
                      isCurrentUser: topUsers[index].userId == currentUserId,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _PodiumPlace extends StatelessWidget {
  const _PodiumPlace({
    required this.user,
    required this.position,
    required this.isCurrentUser,
  });

  final LeaderboardUserModel user;
  final int position;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final (ink, fill, height) = switch (position) {
      1 => (const Color(0xFF6C4900), const Color(0xFFFFE5A5), 51.0),
      2 => (const Color(0xFF344D6B), const Color(0xFFDCE7F5), 40.0),
      _ => (const Color(0xFF77482E), const Color(0xFFF5DFD0), 32.0),
    };
    final first = position == 1;
    final pace = TimeFormatterHelper.formatPace(user.averageTimeSeconds);

    return Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      message: '${user.displayName}\n${user.career} · $pace',
      verticalOffset: 34,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (first) ...[
              CustomPaint(
                size: const Size(22, 15),
                painter: _CrownPainter(ink),
              ),
              const SizedBox(height: 4),
            ],
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(
                  color: isCurrentUser
                      ? AppColors.accent
                      : ink.withValues(alpha: .28),
                  width: isCurrentUser ? 2 : 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: LeaderboardAvatar(user: user, radius: first ? 24 : 19),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              user.displayName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                height: 1.13,
                fontSize: first ? 13 : 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (isCurrentUser)
              const Text(
                'Tú',
                style: TextStyle(
                  color: Color(0xFF0056B3),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            const SizedBox(height: 4),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 3,
              children: [
                Icon(CupertinoIcons.star_fill, size: 11, color: ink),
                Text(
                  '${user.totalStars}',
                  semanticsLabel: '${user.totalStars} estrellas',
                  style: TextStyle(
                    color: ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Container(
              constraints: BoxConstraints(minHeight: height),
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
              decoration: BoxDecoration(
                color: fill,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: ink.withValues(alpha: .12)),
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 3,
                children: [
                  Icon(
                    CupertinoIcons.rosette,
                    color: ink,
                    size: first ? 15 : 13,
                  ),
                  Text(
                    '$position',
                    semanticsLabel: 'Position $position',
                    style: TextStyle(
                      color: ink,
                      fontSize: first ? 20 : 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CrownPainter extends CustomPainter {
  const _CrownPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.6;
    final crown = Path()
      ..moveTo(2, 4)
      ..lineTo(7, 8)
      ..lineTo(11, 2)
      ..lineTo(15, 8)
      ..lineTo(20, 4)
      ..lineTo(18, 13)
      ..lineTo(4, 13)
      ..close();
    canvas.drawPath(crown, paint);
  }

  @override
  bool shouldRepaint(covariant _CrownPainter oldDelegate) =>
      oldDelegate.color != color;
}
