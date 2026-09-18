// Bloque: Pruebas unitarias de modelos y helpers del Leaderboard
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/features/leaderboard/model/leaderboard_user_model.dart';
import 'package:synapse_health/features/leaderboard/utils/time_formatter_helper.dart';

void main() {
  group('LeaderboardUserModel Tests', () {
    test('Serialización y deserialización correcta toMap / fromMap', () {
      final now = DateTime.now();
      final user = LeaderboardUserModel(
        userId: 'u123',
        displayName: 'Dra. Bryan',
        photoUrl: 'https://example.com/photo.png',
        career: 'Medicina Humana',
        gender: 'Hombre',
        totalStars: 45,
        totalQuizTimeSeconds: 150,
        completedQuizzesCount: 5,
        averageTimeSeconds: 30.0,
        lastActiveAt: now,
        rank: 1,
      );

      final map = user.toMap();
      final fromMap = LeaderboardUserModel.fromMap(map);

      expect(fromMap.userId, 'u123');
      expect(fromMap.displayName, 'Dra. Bryan');
      expect(fromMap.totalStars, 45);
      expect(fromMap.totalQuizTimeSeconds, 150);
      expect(fromMap.completedQuizzesCount, 5);
      expect(fromMap.averageTimeSeconds, 30.0);
      expect(fromMap.rank, 1);
      expect(fromMap.rankBadge, '🥇');
      expect(fromMap.formattedTime, '2m 30s');
    });

    test('rankBadge genera emojis y números correctamente', () {
      const u1 = LeaderboardUserModel(
        userId: '1', displayName: 'A', career: 'M', gender: 'H',
        totalStars: 10, totalQuizTimeSeconds: 10, completedQuizzesCount: 1,
        averageTimeSeconds: 10.0, rank: 1,
      );
      expect(u1.rankBadge, '🥇');

      final u2 = u1.copyWith(rank: 2);
      expect(u2.rankBadge, '🥈');

      final u3 = u1.copyWith(rank: 3);
      expect(u3.rankBadge, '🥉');

      const uNull = LeaderboardUserModel(
        userId: '1', displayName: 'A', career: 'M', gender: 'H',
        totalStars: 10, totalQuizTimeSeconds: 10, completedQuizzesCount: 1,
        averageTimeSeconds: 10.0, rank: null,
      );
      expect(uNull.rankBadge, '-');
    });
  });

  group('TimeFormatterHelper Tests', () {
    test('formatSeconds formatea tiempos correctamente', () {
      expect(TimeFormatterHelper.formatSeconds(0), '0:00');
      expect(TimeFormatterHelper.formatSeconds(9), '0:09');
      expect(TimeFormatterHelper.formatSeconds(60), '1:00');
      expect(TimeFormatterHelper.formatSeconds(85), '1:25');
      expect(TimeFormatterHelper.formatSeconds(125), '2:05');
    });

    test('formatPace formatea ritmo de quizzes correctamente', () {
      expect(TimeFormatterHelper.formatPace(0.0), '0s / quiz');
      expect(TimeFormatterHelper.formatPace(45.0), '45s / quiz');
      expect(TimeFormatterHelper.formatPace(60.0), '1m / quiz');
      expect(TimeFormatterHelper.formatPace(75.0), '1m 15s / quiz');
      expect(TimeFormatterHelper.formatPace(130.4), '2m 10s / quiz');
    });
  });
}
