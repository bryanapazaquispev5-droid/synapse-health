import '../../../core/api/aws_data_source.dart';
import '../model/leaderboard_user_model.dart';

class LeaderboardService {
  LeaderboardService({AwsDataSource? source})
    : source = source ?? AwsDataSource.instance;
  final AwsDataSource source;
  static List<LeaderboardUserModel>? _cachedLeaderboard;
  List<LeaderboardUserModel>? get cachedLeaderboard => _cachedLeaderboard;
  void clearCache() => _cachedLeaderboard = null;

  Stream<List<LeaderboardUserModel>> getLeaderboardStream({
    int limit = 50,
  }) => source.watch('api/v1/leaderboard').map((data) {
    final list = AwsDataSource.items(data)
        .map(
          (item) =>
              LeaderboardUserModel.fromMap(item, docId: item['id'] as String),
        )
        .toList();
    list.sort((a, b) {
      final stars = b.totalStars.compareTo(a.totalStars);
      if (stars != 0) return stars;
      if (a.completedQuizzesCount > 0 && b.completedQuizzesCount == 0) {
        return -1;
      }
      if (a.completedQuizzesCount == 0 && b.completedQuizzesCount > 0) return 1;
      final time = a.averageTimeSeconds.compareTo(b.averageTimeSeconds);
      return time != 0
          ? time
          : b.completedQuizzesCount.compareTo(a.completedQuizzesCount);
    });
    final ranked = List<LeaderboardUserModel>.generate(
      list.length < limit ? list.length : limit,
      (i) => list[i].copyWith(rank: i + 1),
    );
    _cachedLeaderboard = ranked;
    return ranked;
  });
}
