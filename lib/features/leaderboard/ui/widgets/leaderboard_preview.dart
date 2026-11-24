import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/connectivity_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/states/app_async_content.dart';
import '../../../personal_progress/ui/progress_ranking_screen.dart';
import '../../api/leaderboard_service.dart';
import '../../model/leaderboard_user_model.dart';
import '../leaderboard_screen.dart';
import 'leaderboard_my_rank_card.dart';

class LeaderboardPreview extends StatefulWidget {
  const LeaderboardPreview({
    super.key,
    required this.user,
    this.service,
    this.connectivity,
  });

  final User user;
  final LeaderboardService? service;
  final ConnectivityService? connectivity;

  @override
  State<LeaderboardPreview> createState() => _LeaderboardPreviewState();
}

class _LeaderboardPreviewState extends State<LeaderboardPreview> {
  late final _service = widget.service ?? LeaderboardService();
  late final _stream = _service.getLeaderboardStream();
  bool _pressed = false;

  void _openRanking() {
    Navigator.of(context).push(
      AppPageRoute(
        child: ProgressRankingScreen(
          user: widget.user,
          previousPageTitle: 'Fichas',
          child: LeaderboardScreen(
            currentUser: widget.user,
            service: _service,
            connectivity: widget.connectivity,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) => AppAsyncStreamBuilder<List<LeaderboardUserModel>>(
    stream: _stream,
    connectivity: widget.connectivity,
    onRetryStream: _service.getLeaderboardStream,
    builder: (context, snapshot, _) {
      final users = snapshot.isAccessFailure
          ? const <LeaderboardUserModel>[]
          : snapshot.data ?? const <LeaderboardUserModel>[];
      final own = users
          .where((user) => user.userId == widget.user.uid)
          .firstOrNull;
      final summary = users.isNotEmpty
          ? 'Tu posición: ${LeaderboardMyRankCard.rankLabel(own)}'
          : !snapshot.isOnline || snapshot.hasError
          ? 'Ranking no disponible'
          : snapshot.hasData
          ? 'Aún no hay participantes en el ranking'
          : 'Cargando posiciones…';
      final reduceMotion = MediaQuery.disableAnimationsOf(context);
      return AnimatedScale(
        scale: _pressed && !reduceMotion ? .985 : 1,
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: Material(
          color: _pressed ? const Color(0xFFDAEAFE) : const Color(0xFFE8F2FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFFCDDFF6)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _openRanking,
            onHighlightChanged: (pressed) => setState(() => _pressed = pressed),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
              child: _PreviewContent(summary: summary, leaders: users.take(3)),
            ),
          ),
        ),
      );
    },
  );
}

class _PreviewContent extends StatelessWidget {
  const _PreviewContent({required this.summary, required this.leaders});
  final String summary;
  final Iterable<LeaderboardUserModel> leaders;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFF0056B3),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Padding(
              padding: EdgeInsets.all(9),
              child: Icon(
                Icons.emoji_events_outlined,
                size: 20,
                color: AppColors.surface,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ranking global',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  summary,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF0056B3),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          const Icon(
            CupertinoIcons.arrow_up_right,
            size: 17,
            color: Color(0xFF0056B3),
            semanticLabel: 'Ver ranking completo',
          ),
        ],
      ),
      if (leaders.isNotEmpty) ...[
        const SizedBox(height: 10),
        const Divider(height: 1, color: Color(0xFFCDDFF6)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 9,
          runSpacing: 6,
          children: [
            for (final leader in leaders)
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '#${leader.rank ?? '-'} ',
                      style: const TextStyle(
                        color: Color(0xFF0056B3),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(text: leader.displayName),
                  ],
                ),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.primaryDark,
                ),
              ),
          ],
        ),
      ],
    ],
  );
}
