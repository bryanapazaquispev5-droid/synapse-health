import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/auth/app_auth.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/states/app_async_content.dart';
import '../api/leaderboard_service.dart';
import '../model/leaderboard_user_model.dart';
import 'widgets/leaderboard_entrance.dart';
import 'widgets/leaderboard_my_rank_card.dart';
import 'widgets/leaderboard_podium_widget.dart';
import 'widgets/leaderboard_user_tile.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({
    super.key,
    required this.currentUser,
    this.service,
    this.connectivity,
  });

  final AppUser currentUser;
  final LeaderboardService? service;
  final ConnectivityService? connectivity;

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late final LeaderboardService _service =
      widget.service ?? LeaderboardService();
  late final _stream = _service.getLeaderboardStream();

  Stream<List<LeaderboardUserModel>> _retry() {
    _service.clearCache();
    return _service.getLeaderboardStream();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: AppAsyncStreamBuilder<List<LeaderboardUserModel>>(
        stream: _stream,
        connectivity: widget.connectivity,
        onRetryStream: _retry,
        builder: (context, snapshot, retry) {
          final users = snapshot.isAccessFailure
              ? const <LeaderboardUserModel>[]
              : snapshot.data ?? const <LeaderboardUserModel>[];
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: CustomScrollView(
                key: const PageStorageKey('global-leaderboard'),
                slivers: [
                  const SliverToBoxAdapter(child: _LeaderboardHeading()),
                  if (!snapshot.hasData || users.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppAsyncStatus(
                        snapshot: snapshot,
                        isEmpty: users.isEmpty,
                        onRetry: retry,
                        emptyTitle: 'Aún no hay participantes en el ranking',
                        emptyMessage:
                            'Los resultados de los quizzes aparecerán aquí.',
                        emptyIcon: CupertinoIcons.chart_bar,
                        errorMessage:
                            'No se pudo cargar el ranking. Inténtalo de nuevo.',
                      ),
                    )
                  else ...[
                    SliverToBoxAdapter(
                      child: AppAsyncNotice(snapshot: snapshot, onRetry: retry),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      sliver: SliverToBoxAdapter(
                        child: LeaderboardMyRankCard(
                          currentUser: users
                              .where((u) => u.userId == widget.currentUser.uid)
                              .firstOrNull,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: _SectionTitle('Primeros puestos'),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: LeaderboardPodiumWidget(
                          topUsers: users.take(3).toList(),
                          currentUserId: widget.currentUser.uid,
                        ),
                      ),
                    ),
                    if (users.length > 3) ...[
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(top: 22),
                          child: _SectionTitle('Más participantes'),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList.builder(
                          itemCount: users.length - 3,
                          itemBuilder: (context, index) {
                            final user = users[index + 3];
                            final tile = LeaderboardUserTile(
                              user: user,
                              isCurrentUser:
                                  user.userId == widget.currentUser.uid,
                              showDivider: index < users.length - 4,
                            );
                            return index < 6
                                ? LeaderboardEntrance(
                                    key: ValueKey(user.userId),
                                    order: index,
                                    child: tile,
                                  )
                                : tile;
                          },
                        ),
                      ),
                    ],
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}

class _LeaderboardHeading extends StatelessWidget {
  const _LeaderboardHeading();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: const Text(
            'Ranking global',
            style: TextStyle(
              fontSize: 31,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.9,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ordenado por estrellas y velocidad',
          style: TextStyle(fontSize: 14, color: AppColors.primaryDark),
        ),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
    child: Semantics(
      header: true,
      child: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
