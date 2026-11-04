// Global leaderboard screen assembler
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/auth/app_auth.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/states/app_async_content.dart';
import '../api/leaderboard_service.dart';
import '../model/leaderboard_user_model.dart';
import 'widgets/leaderboard_my_rank_card.dart';
import 'widgets/leaderboard_podium_widget.dart';
import 'widgets/leaderboard_user_tile.dart';

// Main leaderboard view
class LeaderboardScreen extends StatefulWidget {
  final AppUser currentUser;

  const LeaderboardScreen({super.key, required this.currentUser});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with AutomaticKeepAliveClientMixin {
  late final Stream<List<LeaderboardUserModel>> _leaderboardStream;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _leaderboardStream = LeaderboardService().getLeaderboardStream();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: AppAsyncStreamBuilder<List<LeaderboardUserModel>>(
          stream: _leaderboardStream,
          onRetryStream: () {
            LeaderboardService().clearCache();
            return LeaderboardService().getLeaderboardStream();
          },
          builder: (context, snapshot, retry) {
            final users = snapshot.data ?? [];
            if (!snapshot.hasData ||
                users.isEmpty ||
                snapshot.isAccessFailure) {
              return AppAsyncStatus(
                snapshot: snapshot,
                isEmpty: users.isEmpty,
                onRetry: retry,
                emptyTitle: 'No participants in the leaderboard yet',
                emptyMessage: 'Available results will appear here.',
                emptyIcon: CupertinoIcons.chart_bar,
                errorMessage:
                    'Could not load the leaderboard. Please try again.',
              );
            }

            final myRankUser = users.cast<LeaderboardUserModel?>().firstWhere(
              (u) => u?.userId == widget.currentUser.uid,
              orElse: () => null,
            );
            final restUsers = users.length > 3
                ? users.sublist(3)
                : <LeaderboardUserModel>[];

            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Elite Leaderboard',
                          style: TextStyle(
                            fontFamily: '.SF Pro Display',
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Ranked by stars and speed',
                          style: TextStyle(
                            fontFamily: '.SF Pro Text',
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: AppAsyncNotice(snapshot: snapshot, onRetry: retry),
                ),
                SliverToBoxAdapter(
                  child: LeaderboardMyRankCard(
                    currentUser: myRankUser,
                    fallbackUser: widget.currentUser,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 12),
                    child: LeaderboardPodiumWidget(
                      topUsers: users.take(3).toList(),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final u = restUsers[index];
                    return LeaderboardUserTile(
                      user: u,
                      isCurrentUser: u.userId == widget.currentUser.uid,
                    );
                  }, childCount: restUsers.length),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 90)),
              ],
            );
          },
        ),
      ),
    );
  }
}
