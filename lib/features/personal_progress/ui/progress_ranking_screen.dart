import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../leaderboard/ui/leaderboard_screen.dart';

/// Preserves the existing ranking screen and gives its pushed route a back action.
class ProgressRankingScreen extends StatelessWidget {
  const ProgressRankingScreen({super.key, required this.user, this.child});
  final User user;
  final Widget? child;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: const CupertinoNavigationBar(
      middle: Text('Ranking global'),
      previousPageTitle: 'Progreso',
    ),
    body: child ?? LeaderboardScreen(currentUser: user),
  );
}
