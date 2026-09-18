// Bloque: Tests unitarios y de widgets para Leaderboard UI
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
        displayName: 'Dra. María Pérez',
        career: 'Medicina Humana',
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
        career: 'Enfermería',
        gender: 'Hombre',
        totalStars: 40,
        totalQuizTimeSeconds: 360,
        completedQuizzesCount: 12,
        averageTimeSeconds: 30.0,
        rank: 2,
      ),
      const LeaderboardUserModel(
        userId: 'u3',
        displayName: 'Dra. Ana López',
        career: 'Odontología',
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
        career: 'Nutrición',
        gender: 'Hombre',
        totalStars: 30,
        totalQuizTimeSeconds: 500,
        completedQuizzesCount: 10,
        averageTimeSeconds: 50.0,
        rank: 4,
      ),
    ];

    testWidgets('LeaderboardPodiumWidget renderiza los primeros 3 puestos correctamente', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LeaderboardPodiumWidget(topUsers: mockUsers.take(3).toList()),
          ),
        ),
      );

      expect(find.text('Dra. María Pérez'), findsOneWidget);
      expect(find.text('Dr. Carlos Vega'), findsOneWidget);
      expect(find.text('Dra. Ana López'), findsOneWidget);
      expect(find.text('45'), findsOneWidget);
      expect(find.text('40'), findsOneWidget);
      expect(find.text('35'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('LeaderboardUserTile renderiza usuario con rango 4+ y etiqueta Tú', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LeaderboardUserTile(user: mockUsers[3], isCurrentUser: true),
          ),
        ),
      );

      expect(find.text('#4'), findsOneWidget);
      expect(find.text('Dr. Roberto Soto'), findsOneWidget);
      expect(find.text('Nutrición'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(find.text('Tú'), findsOneWidget);
    });

    testWidgets('LeaderboardMyRankCard muestra posición y motivación del usuario', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LeaderboardMyRankCard(currentUser: mockUsers[0]),
          ),
        ),
      );

      expect(find.text('#1'), findsOneWidget);
      expect(find.text('Tu Posición Global'), findsOneWidget);
      expect(find.text('¡En el Podio! 🏆'), findsOneWidget);
      expect(find.text('45 Estrellas'), findsOneWidget);
    });
  });
}
