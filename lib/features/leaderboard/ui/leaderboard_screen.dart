// Bloque: Pantalla ensambladora del Ranking Global / Leaderboard
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../api/leaderboard_service.dart';
import '../model/leaderboard_user_model.dart';
import 'widgets/leaderboard_my_rank_card.dart';
import 'widgets/leaderboard_podium_widget.dart';
import 'widgets/leaderboard_user_tile.dart';

// Bloque: Vista principal del Leaderboard
class LeaderboardScreen extends StatelessWidget {
  final User currentUser;

  const LeaderboardScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<List<LeaderboardUserModel>>(
          stream: LeaderboardService().getLeaderboardStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator(radius: 14));
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error al cargar el ranking', style: TextStyle(fontFamily: '.SF Pro Text', color: AppColors.systemRed)));
            }
            final users = snapshot.data ?? [];
            if (users.isEmpty) {
              return const Center(child: Text('Aún no hay participantes en el ranking', style: TextStyle(fontFamily: '.SF Pro Text', color: AppColors.textMuted, fontSize: 14)));
            }

            final myRankUser = users.cast<LeaderboardUserModel?>().firstWhere((u) => u?.userId == currentUser.uid, orElse: () => null);
            final restUsers = users.length > 3 ? users.sublist(3) : <LeaderboardUserModel>[];

            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ranking de Élite', style: TextStyle(fontFamily: '.SF Pro Display', fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.primary)),
                        SizedBox(height: 2),
                        Text('Ordenado por estrellas y velocidad', style: TextStyle(fontFamily: '.SF Pro Text', fontSize: 13, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: LeaderboardMyRankCard(currentUser: myRankUser, fallbackUser: currentUser)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 12),
                    child: LeaderboardPodiumWidget(topUsers: users.take(3).toList()),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final u = restUsers[index];
                      return LeaderboardUserTile(user: u, isCurrentUser: u.userId == currentUser.uid);
                    },
                    childCount: restUsers.length,
                  ),
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
