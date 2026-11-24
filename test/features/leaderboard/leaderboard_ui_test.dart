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

    testWidgets('LeaderboardPodiumWidget renders the top 3 places correctly', (
      tester,
    ) async {
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

    testWidgets(
      'Podium places the winner in the center at phone and tablet widths',
      (tester) async {
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final longName = mockUsers.first.copyWith(
          displayName: 'María Alejandra Fernández de la Cruz',
          totalStars: 123456789,
        );
        for (final size in [const Size(360, 800), const Size(800, 600)]) {
          await tester.binding.setSurfaceSize(size);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: LeaderboardPodiumWidget(
                  topUsers: [longName, ...mockUsers.skip(1).take(2)],
                ),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 500));
          final winner = find.text(longName.displayName);
          expect(tester.getCenter(winner).dx, closeTo(size.width / 2, 1));
          expect(
            tester.getCenter(find.text(mockUsers[1].displayName)).dx,
            lessThan(size.width / 2),
          );
          expect(
            tester.getCenter(find.text(mockUsers[2].displayName)).dx,
            greaterThan(size.width / 2),
          );
          expect(find.text('123456789'), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.tap(winner);
          await tester.pump(const Duration(milliseconds: 250));
          expect(
            find.textContaining(longName.career, findRichText: true),
            findsOneWidget,
          );
          await tester.pumpWidget(const SizedBox());
          await tester.pump();
        }
      },
    );

    testWidgets('Podium staggers the entrance and respects reduced motion', (
      tester,
    ) async {
      Widget podium(bool reduced) => MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
          child: child!,
        ),
        home: Scaffold(
          body: LeaderboardPodiumWidget(topUsers: mockUsers.take(3).toList()),
        ),
      );
      Finder opacityFor(String id) => find.descendant(
        of: find.byKey(ValueKey(id)),
        matching: find.byType(Opacity),
      );
      double opacity(String id) =>
          tester.widget<Opacity>(opacityFor(id)).opacity;
      await tester.pumpWidget(podium(false));
      expect(opacity('u1'), 0);
      await tester.pump(const Duration(milliseconds: 140));
      expect(opacity('u1'), greaterThan(opacity('u3')));
      await tester.pump(const Duration(milliseconds: 400));
      expect(opacity('u1'), 1);
      expect(opacity('u3'), 1);
      await tester.pumpWidget(podium(true));
      expect(opacityFor('u1'), findsNothing);
      expect(find.text(mockUsers.first.displayName), findsOneWidget);
    });

    testWidgets(
      'LeaderboardUserTile renders a user with rank 4+ and the Tú label',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LeaderboardUserTile(
                user: mockUsers[3],
                isCurrentUser: true,
              ),
            ),
          ),
        );

        expect(find.text('#4'), findsOneWidget);
        expect(find.text('Dr. Roberto Soto'), findsOneWidget);
        expect(find.text('Nutrition'), findsOneWidget);
        expect(find.text('30'), findsOneWidget);
        expect(find.text('Tú'), findsOneWidget);
      },
    );

    testWidgets(
      'LeaderboardMyRankCard displays the user rank and quiz metrics',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LeaderboardMyRankCard(currentUser: mockUsers[0]),
            ),
          ),
        );

        expect(find.text('#1'), findsOneWidget);
        expect(find.text('Tu posición global'), findsOneWidget);
        expect(find.text('45 estrellas'), findsOneWidget);
      },
    );
  });
}
