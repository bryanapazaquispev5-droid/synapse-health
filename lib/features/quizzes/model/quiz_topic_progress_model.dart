// Bloque: Modelo de Progreso de Tema de Quiz y Sistema de Intentos
import 'package:cloud_firestore/cloud_firestore.dart';
import 'quiz_attempt_model.dart';

class QuizTopicProgressModel {
  // Bloque: Constante de límite estricto FIFO para el historial de intentos
  static const int maxHistoryEntries = 3;

  // Bloque: Atributos del progreso por tema
  final String topicId;
  final String areaId;
  final int currentAttemptNumber;
  final QuizAttemptModel activeAttempt;
  final List<QuizAttemptModel> history;
  final DateTime? updatedAt;

  // Bloque: Constructor principal constante
  const QuizTopicProgressModel({
    required this.topicId,
    required this.areaId,
    required this.currentAttemptNumber,
    required this.activeAttempt,
    required this.history,
    this.updatedAt,
  });

  // Bloque: Helpers de consulta y presentación
  bool isQuestionLocked(String quizId) {
    return activeAttempt.isQuizLocked(quizId);
  }

  String get starsDisplay {
    return '${activeAttempt.totalEarnedStars} / ${activeAttempt.totalMaxStars}';
  }

  double get starsPercentage {
    if (activeAttempt.totalMaxStars <= 0) return 0.0;
    return (activeAttempt.totalEarnedStars / activeAttempt.totalMaxStars)
        .clamp(0.0, 1.0);
  }

  // Bloque: Constructor de progreso inicial vacío
  factory QuizTopicProgressModel.empty({
    required String topicId,
    required String areaId,
    int totalMaxStars = 0,
  }) {
    return QuizTopicProgressModel(
      topicId: topicId,
      areaId: areaId,
      currentAttemptNumber: 1,
      activeAttempt: QuizAttemptModel.empty(
        attemptNumber: 1,
        totalMaxStars: totalMaxStars,
      ),
      history: const [],
      updatedAt: DateTime.now(),
    );
  }

  // Bloque: Deserializador seguro tolerante a Firestore y JSON
  factory QuizTopicProgressModel.fromMap(
    Map<String, dynamic> map, {
    String? topicId,
    String? areaId,
  }) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    int parseInt(dynamic val, int fallback) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? fallback;
      return fallback;
    }

    final String resolvedTopicId =
        map['topicId']?.toString() ?? topicId ?? '';
    final String resolvedAreaId = map['areaId']?.toString() ?? areaId ?? '';
    final int attemptNum = parseInt(map['currentAttemptNumber'], 1);

    final rawActive = map['activeAttempt'];
    final QuizAttemptModel parsedActive = rawActive is Map
        ? QuizAttemptModel.fromMap(Map<String, dynamic>.from(rawActive))
        : QuizAttemptModel.empty(attemptNumber: attemptNum);

    final rawHistory = map['history'];
    final List<QuizAttemptModel> parsedHistory = [];

    if (rawHistory is List) {
      for (final item in rawHistory) {
        if (item is Map) {
          parsedHistory.add(
            QuizAttemptModel.fromMap(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    // Bloque: Asegurar estricto límite FIFO de historial a un máximo de 3 entradas
    final List<QuizAttemptModel> trimmedHistory =
        parsedHistory.length > maxHistoryEntries
            ? parsedHistory.sublist(parsedHistory.length - maxHistoryEntries)
            : parsedHistory;

    return QuizTopicProgressModel(
      topicId: resolvedTopicId,
      areaId: resolvedAreaId,
      currentAttemptNumber: attemptNum,
      activeAttempt: parsedActive,
      history: trimmedHistory,
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  // Bloque: Serializador a Map compatible con Firestore
  Map<String, dynamic> toMap() {
    return {
      'topicId': topicId,
      'areaId': areaId,
      'currentAttemptNumber': currentAttemptNumber,
      'activeAttempt': activeAttempt.toMap(),
      'history': history.map((e) => e.toMap()).toList(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Bloque: Método para reintentar el tema archivando el intento actual con FIFO estricto
  QuizTopicProgressModel archiveCurrentAttemptAndReset({
    required int totalMaxStars,
  }) {
    final completedAttempt = activeAttempt.copyWith(
      completedAt: DateTime.now(),
    );

    final updatedHistory = List<QuizAttemptModel>.from(history)
      ..add(completedAttempt);

    final trimmedHistory = updatedHistory.length > maxHistoryEntries
        ? updatedHistory.sublist(updatedHistory.length - maxHistoryEntries)
        : updatedHistory;

    final nextAttemptNumber = currentAttemptNumber + 1;

    return QuizTopicProgressModel(
      topicId: topicId,
      areaId: areaId,
      currentAttemptNumber: nextAttemptNumber,
      activeAttempt: QuizAttemptModel.empty(
        attemptNumber: nextAttemptNumber,
        totalMaxStars: totalMaxStars,
      ),
      history: trimmedHistory,
      updatedAt: DateTime.now(),
    );
  }

  // Bloque: Clonación inmutable con copyWith
  QuizTopicProgressModel copyWith({
    String? topicId,
    String? areaId,
    int? currentAttemptNumber,
    QuizAttemptModel? activeAttempt,
    List<QuizAttemptModel>? history,
    DateTime? updatedAt,
  }) {
    return QuizTopicProgressModel(
      topicId: topicId ?? this.topicId,
      areaId: areaId ?? this.areaId,
      currentAttemptNumber: currentAttemptNumber ?? this.currentAttemptNumber,
      activeAttempt: activeAttempt ?? this.activeAttempt,
      history: history ?? this.history,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
