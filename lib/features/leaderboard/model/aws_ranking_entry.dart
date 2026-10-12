/// Public pseudonymous projection; contains no Cognito identity or profile.
class AwsRankingEntry {
  AwsRankingEntry(Map<String, dynamic> data) {
    const allowed = {
      'publicId',
      'alias',
      'rank',
      'totalStars',
      'totalQuizTimeSeconds',
      'completedQuizzesCount',
      'averageTimeSeconds',
    };
    if (data.keys.any((key) => !allowed.contains(key))) {
      throw const FormatException('Unsafe ranking response.');
    }
    publicId = data['publicId'] as String;
    alias = data['alias'] as String;
    rank = data['rank'] as int;
    totalStars = data['totalStars'] as int;
    totalQuizTimeSeconds = data['totalQuizTimeSeconds'] as int;
    completedQuizzesCount = data['completedQuizzesCount'] as int;
    averageTimeSeconds = (data['averageTimeSeconds'] as num).toDouble();
    if (!RegExp(
          r'^[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$',
        ).hasMatch(publicId) ||
        !RegExp(r'^Estudiante [a-f0-9]{8}$').hasMatch(alias) ||
        rank < 1 ||
        totalStars < 0 ||
        totalQuizTimeSeconds < 0 ||
        completedQuizzesCount < 1 ||
        !averageTimeSeconds.isFinite ||
        averageTimeSeconds < 0) {
      throw const FormatException('Invalid ranking entry.');
    }
  }
  late final String publicId, alias;
  late final int rank, totalStars, totalQuizTimeSeconds, completedQuizzesCount;
  late final double averageTimeSeconds;
}

class AwsRankingPage {
  const AwsRankingPage({required this.items, this.nextCursor});
  final List<AwsRankingEntry> items;
  final String? nextCursor;
}
