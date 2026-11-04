// Block: Immutable user model for the leaderboard

class LeaderboardUserModel {
  // Block: Immutable performance and rank attributes
  final String userId;
  final String displayName;
  final String? photoUrl;
  final String career;
  final String gender;
  final int totalStars;
  final int totalQuizTimeSeconds;
  final int completedQuizzesCount;
  final double averageTimeSeconds;
  final DateTime? lastActiveAt;
  final int? rank;

  const LeaderboardUserModel({
    required this.userId,
    required this.displayName,
    this.photoUrl,
    required this.career,
    required this.gender,
    required this.totalStars,
    required this.totalQuizTimeSeconds,
    required this.completedQuizzesCount,
    required this.averageTimeSeconds,
    this.lastActiveAt,
    this.rank,
  });

  // Block: Presentation helpers
  String get formattedTime {
    final m = totalQuizTimeSeconds ~/ 60;
    final s = totalQuizTimeSeconds % 60;
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }

  String get rankBadge {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return rank != null ? '#$rank' : '-';
  }

  // Block: Safe deserializer from Map
  factory LeaderboardUserModel.fromMap(
    Map<String, dynamic> map, {
    String? docId,
    int? rank,
  }) {
    DateTime? parseDate(dynamic val) => (val is String
        ? DateTime.tryParse(val)
        : (val is DateTime ? val : null));
    int parseInt(dynamic val) =>
        val is num ? val.toInt() : (int.tryParse(val?.toString() ?? '') ?? 0);
    double parseDouble(dynamic val) => val is num
        ? val.toDouble()
        : (double.tryParse(val?.toString() ?? '') ?? 0.0);

    return LeaderboardUserModel(
      userId: map['userId']?.toString() ?? docId ?? '',
      displayName: map['displayName']?.toString() ?? 'Student',
      photoUrl: map['photoUrl']?.toString(),
      career: map['career']?.toString() ?? 'Human Medicine',
      gender: map['gender']?.toString() ?? 'Male',
      totalStars: parseInt(map['totalStars']),
      totalQuizTimeSeconds: parseInt(map['totalQuizTimeSeconds']),
      completedQuizzesCount: parseInt(map['completedQuizzesCount']),
      averageTimeSeconds: parseDouble(map['averageTimeSeconds']),
      lastActiveAt: parseDate(map['lastActiveAt']),
      rank: rank ?? (map['rank'] != null ? parseInt(map['rank']) : null),
    );
  }

  // Block: Map serializer for leaderboard data
  Map<String, dynamic> toMap() => {
    'userId': userId,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'career': career,
    'gender': gender,
    'totalStars': totalStars,
    'totalQuizTimeSeconds': totalQuizTimeSeconds,
    'completedQuizzesCount': completedQuizzesCount,
    'averageTimeSeconds': averageTimeSeconds,
    'lastActiveAt': lastActiveAt?.toIso8601String(),
    if (rank != null) 'rank': rank,
  };

  // Block: Immutable clone using copyWith
  LeaderboardUserModel copyWith({
    String? userId,
    String? displayName,
    String? photoUrl,
    String? career,
    String? gender,
    int? totalStars,
    int? totalQuizTimeSeconds,
    int? completedQuizzesCount,
    double? averageTimeSeconds,
    DateTime? lastActiveAt,
    int? rank,
  }) => LeaderboardUserModel(
    userId: userId ?? this.userId,
    displayName: displayName ?? this.displayName,
    photoUrl: photoUrl ?? this.photoUrl,
    career: career ?? this.career,
    gender: gender ?? this.gender,
    totalStars: totalStars ?? this.totalStars,
    totalQuizTimeSeconds: totalQuizTimeSeconds ?? this.totalQuizTimeSeconds,
    completedQuizzesCount: completedQuizzesCount ?? this.completedQuizzesCount,
    averageTimeSeconds: averageTimeSeconds ?? this.averageTimeSeconds,
    lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    rank: rank ?? this.rank,
  );
}
