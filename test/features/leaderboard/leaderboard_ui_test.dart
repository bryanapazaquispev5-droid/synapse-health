// Section: Unit and widget tests for the leaderboard UI
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/features/leaderboard/model/leaderboard_user_model.dart';
import 'package:synapse_health/features/leaderboard/ui/widgets/leaderboard_my_rank_card.dart';
import 'package:synapse_health/features/leaderboard/ui/widgets/leaderboard_podium_widget.dart';
import 'package:synapse_health/features/leaderboard/ui/widgets/leaderboard_user_tile.dart';

void main() {
  group('Leaderboard UI Widget Tests', () {
    final mockUsers = [
      const LeaderboardUserModel(
        userId: 'u1',
        displayName: 'Dr. Maria Perez',
        career: 'Human Medicine',
        gender: 'Mujer',
        totalStars: 45,
        totalQuizTimeSeconds: 300,
        completedQuizzesCount: 15,
        averageTimeSeconds: 20.0,
        rank: 1,
      ),
      const LeaderboardUserModel(
        userId: 'u2',
        displayName: 'Dr. Carlos Vega',
        career: 'Nursing',
        gender: 'Hombre',
        totalStars: 40,
        totalQuizTimeSeconds: 360,
        completedQuizzesCount: 12,
        averageTimeSeconds: 30.0,
        rank: 2,
      ),
      const LeaderboardUserModel(
        userId: 'u3',
        displayName: 'Dr. Ana Lopez',
        career: 'Dentistry',
        gender: 'Mujer',
        totalStars: 35,
        totalQuizTimeSeconds: 420,
        completedQuizzesCount: 10,
        averageTimeSeconds: 42.0,
        rank: 3,
      ),
      const LeaderboardUserModel(
        userId: 'u4',
        displayName: 'Dr. Roberto Soto',
        career: 'Nutrition',
        gender: 'Hombre',
        totalStars: 30,
        totalQuizTimeSeconds: 500,
        completedQuizzesCount: 10,
        averageTimeSeconds: 50.0,
        rank: 4,
      ),
    ];

    testWidgets('LeaderboardPodiumWidget renders the top 3 places correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LeaderboardPodiumWidget(topUsers: mockUsers.take(3).toList()),
          ),
        ),
      );

      expect(find.text('Dr. Maria Perez'), findsOneWidget);
      expect(find.text('Dr. Carlos Vega'), findsOneWidget);
      expect(find.text('Dr. Ana Lopez'), findsOneWidget);
      expect(find.text('45'), findsOneWidget);
      expect(find.text('40'), findsOneWidget);
      expect(find.text('35'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('LeaderboardUserTile renders a user with rank 4+ and the You label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LeaderboardUserTile(user: mockUsers[3], isCurrentUser: true),
          ),
        ),
      );

      expect(find.text('#4'), findsOneWidget);
      expect(find.text('Dr. Roberto Soto'), findsOneWidget);
      expect(find.text('Nutrition'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(find.text('You'), findsOneWidget);
    });

    testWidgets('LeaderboardMyRankCard displays the user rank and motivation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LeaderboardMyRankCard(currentUser: mockUsers[0]),
          ),
        ),
      );

      expect(find.text('#1'), findsOneWidget);
      expect(find.text('Your Global Rank'), findsOneWidget);
      expect(find.text('You are on the podium! 🏆'), findsOneWidget);
      expect(find.text('45 stars'), findsOneWidget);
    });
  });
}
