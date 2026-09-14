/// Modelo de Dominio para los Quizzes Clínicos de Synapse Health
/// Soporta preguntas de 3 alternativas con retroalimentación médica inmediata
class QuizModel {
  final String id;
  final String areaId;
  final String topicId;
  final String type; // 'multiple_choice', 'matching', 'ordering'
  final String question;
  final List<String> options;
  final int correctIndex;
  final String rationale;
  final String sourceBook;
  final int order;

  const QuizModel({
    required this.id,
    required this.areaId,
    required this.topicId,
    this.type = 'multiple_choice',
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.rationale,
    required this.sourceBook,
    this.order = 1,
  });

  factory QuizModel.fromMap(Map<String, dynamic> map, String documentId) {
    List<String> parseOptions(dynamic raw) {
      if (raw is List) {
        return raw.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
      }
      return const [];
    }

    int parseIndex(dynamic raw) {
      if (raw is int) return raw;
      if (raw is num) return raw.toInt();
      if (raw != null) return int.tryParse(raw.toString()) ?? 0;
      return 0;
    }

    return QuizModel(
      id: documentId,
      areaId: map['areaId']?.toString() ?? '',
      topicId: map['topicId']?.toString() ?? '',
      type: map['type']?.toString() ?? 'multiple_choice',
      question: map['question']?.toString() ?? '',
      options: parseOptions(map['options']),
      correctIndex: parseIndex(map['correctIndex']),
      rationale: map['rationale']?.toString() ?? '',
      sourceBook: map['sourceBook']?.toString() ?? map['source']?.toString() ?? '',
      order: parseIndex(map['order']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'areaId': areaId,
      'topicId': topicId,
      'type': type,
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
      'rationale': rationale,
      'sourceBook': sourceBook,
      'order': order,
    };
  }

  String get typeLabel {
    switch (type) {
      case 'matching':
        return 'Para Relacionar';
      case 'ordering':
        return 'Para Ordenar';
      case 'case_study':
        return 'Caso Clínico';
      case 'single_choice':
      case 'multiple_choice':
      default:
        return 'Selección Simple';
    }
  }
}
