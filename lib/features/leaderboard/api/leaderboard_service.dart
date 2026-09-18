// Bloque: Servicio de Ranking y Leaderboard Firestore
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_constants.dart';
import '../model/leaderboard_user_model.dart';

class LeaderboardService {
  // Bloque: Singleton con dependencias inyectables
  static final LeaderboardService _instance = LeaderboardService._internal();
  factory LeaderboardService({FirebaseFirestore? firestore, FirebaseAuth? auth}) {
    if (firestore != null || auth != null) {
      return LeaderboardService._internal(firestore: firestore, auth: auth);
    }
    return _instance;
  }

  LeaderboardService._internal({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Bloque: Stream del Leaderboard ordenado en memoria con ranking asignado
  Stream<List<LeaderboardUserModel>> getLeaderboardStream({int limit = 50}) {
    return _firestore
        .collection(AppConstants.FIRESTORE_LEADERBOARD)
        .snapshots()
        .map((snapshot) {
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
      return List<LeaderboardUserModel>.generate(limited.length, (i) {
        return limited[i].copyWith(rank: i + 1);
      });
    });
  }

  // Bloque: Registro acumulado de quiz completado y actualización de métricas
  Future<void> recordCompletedQuiz({
    required String uid,
    required int earnedStars,
    required int durationSeconds,
  }) async {
    try {
      final docRef = _firestore.collection(AppConstants.FIRESTORE_LEADERBOARD).doc(uid);
      final snapshot = await docRef.get();
      final current = snapshot.exists && snapshot.data() != null
          ? LeaderboardUserModel.fromMap(snapshot.data()!, docId: uid)
          : null;

      final newTotalStars = (current?.totalStars ?? 0) + earnedStars;
      final newTotalTime = (current?.totalQuizTimeSeconds ?? 0) + durationSeconds;
      final newCompleted = (current?.completedQuizzesCount ?? 0) + 1;
      final newAvg = newCompleted > 0 ? (newTotalTime / newCompleted) : 0.0;

      String name = current?.displayName ?? '';
      String career = current?.career ?? 'Medicina Humana';
      String gender = current?.gender ?? 'Hombre';
      String? photoUrl = current?.photoUrl;

      if (current == null) {
        final userDoc = await _firestore.collection(AppConstants.FIRESTORE_USERS).doc(uid).get();
        final userData = userDoc.data() ?? {};
        name = userData['name']?.toString() ?? _auth.currentUser?.displayName ?? 'Estudiante';
        career = userData['career']?.toString() ?? 'Medicina Humana';
        gender = userData['gender']?.toString() ?? 'Hombre';
        photoUrl = userData['photoUrl']?.toString() ?? _auth.currentUser?.photoURL;
      }

      await docRef.set({
        'userId': uid,
        'displayName': name,
        'photoUrl': photoUrl,
        'career': career,
        'gender': gender,
        'totalStars': newTotalStars,
        'totalQuizTimeSeconds': newTotalTime,
        'completedQuizzesCount': newCompleted,
        'averageTimeSeconds': double.parse(newAvg.toStringAsFixed(1)),
        'lastActiveAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e, stack) {
      developer.log('Error registrando quiz en leaderboard: $e',
          name: 'LeaderboardService', error: e, stackTrace: stack);
    }
  }

  // Bloque: Sincronización de perfil del usuario en la colección de ranking
  Future<void> syncUserProfile({
    required String uid,
    required String displayName,
    required String career,
    required String gender,
    String? photoUrl,
  }) async {
    try {
      final docRef = _firestore.collection(AppConstants.FIRESTORE_LEADERBOARD).doc(uid);
      await docRef.set({
        'userId': uid,
        'displayName': displayName,
        'career': career,
        'gender': gender,
        'photoUrl': photoUrl,
        'lastActiveAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      developer.log('Error sincronizando perfil en leaderboard: $e', name: 'LeaderboardService');
    }
  }

  // Bloque: Inicialización de usuario con sus estadísticas previas
  Future<void> syncUserInitialStats(String uid) async {
    try {
      final docRef = _firestore.collection(AppConstants.FIRESTORE_LEADERBOARD).doc(uid);
      final snapshot = await docRef.get();
      if (snapshot.exists) return;

      final userDoc = await _firestore.collection(AppConstants.FIRESTORE_USERS).doc(uid).get();
      final userData = userDoc.data() ?? {};

      final progressSnap = await _firestore
          .collection(AppConstants.FIRESTORE_USERS)
          .doc(uid)
          .collection('quiz_topics_progress')
          .get();

      int initialStars = 0;
      for (final doc in progressSnap.docs) {
        final active = doc.data()['activeAttempt'];
        if (active is Map && active['totalEarnedStars'] is num) {
          initialStars += (active['totalEarnedStars'] as num).toInt();
        }
      }

      await docRef.set({
        'userId': uid,
        'displayName': userData['name'] ?? _auth.currentUser?.displayName ?? 'Estudiante',
        'photoUrl': userData['photoUrl'] ?? _auth.currentUser?.photoURL,
        'career': userData['career'] ?? 'Medicina Humana',
        'gender': userData['gender'] ?? 'Hombre',
        'totalStars': initialStars,
        'totalQuizTimeSeconds': 0,
        'completedQuizzesCount': initialStars > 0 ? (initialStars ~/ 3) : 0,
        'averageTimeSeconds': 0.0,
        'lastActiveAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      developer.log('Error inicializando estadísticas en leaderboard: $e', name: 'LeaderboardService');
    }
  }
}
