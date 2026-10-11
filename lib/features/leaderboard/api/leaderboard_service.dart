// Bloque: Servicio de Ranking y Leaderboard Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../model/leaderboard_user_model.dart';

class LeaderboardService {
  // Bloque: Singleton con dependencias inyectables
  static final LeaderboardService _instance = LeaderboardService._internal();
  factory LeaderboardService({FirebaseFirestore? firestore}) {
    if (firestore != null) {
      return LeaderboardService._internal(firestore: firestore);
    }
    return _instance;
  }

  LeaderboardService._internal({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // Bloque: Caché en memoria y stream compartido para evitar recargas y parpadeos
  List<LeaderboardUserModel>? _cachedLeaderboard;
  Stream<List<LeaderboardUserModel>>? _leaderboardStream;
  int _cachedLimit = 50;

  /// Retorna la última lista clasificada en caché de forma sincrónica
  List<LeaderboardUserModel>? get cachedLeaderboard => _cachedLeaderboard;

  /// Invalida la caché del leaderboard y reinicia la suscripción compartida
  void clearCache() {
    _cachedLeaderboard = null;
    _leaderboardStream = null;
  }

  // Bloque: Stream del Leaderboard optimizado con caché persistente y transmisión compartida
  Stream<List<LeaderboardUserModel>> getLeaderboardStream({int limit = 50}) async* {
    if (_cachedLeaderboard != null) {
      yield _cachedLeaderboard!.take(limit).toList();
    }

    if (_leaderboardStream == null || _cachedLimit != limit) {
      _cachedLimit = limit;
      _leaderboardStream = _firestore
          .collection(AppConstants.FIRESTORE_LEADERBOARD)
          .snapshots()
          .map((snapshot) => _processSnapshot(snapshot, limit))
          .asBroadcastStream(onCancel: (_) {});
    }

    yield* _leaderboardStream!;
  }

  List<LeaderboardUserModel> _processSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
    int limit,
  ) {
    final list = snapshot.docs
        .map((doc) => LeaderboardUserModel.fromMap(doc.data(), docId: doc.id))
        .toList();

    list.sort((a, b) {
      final starsComp = b.totalStars.compareTo(a.totalStars);
      if (starsComp != 0) return starsComp;

      if (a.completedQuizzesCount > 0 && b.completedQuizzesCount == 0) return -1;
      if (a.completedQuizzesCount == 0 && b.completedQuizzesCount > 0) return 1;

      final timeComp = a.averageTimeSeconds.compareTo(b.averageTimeSeconds);
      if (timeComp != 0) return timeComp;

      return b.completedQuizzesCount.compareTo(a.completedQuizzesCount);
    });

    final limited = list.take(limit).toList();
    final ranked = List<LeaderboardUserModel>.generate(limited.length, (i) {
      return limited[i].copyWith(rank: i + 1);
    });
    _cachedLeaderboard = ranked;
    return ranked;
  }

  // Ranking metrics are published only by a trusted server, never this client.
}
