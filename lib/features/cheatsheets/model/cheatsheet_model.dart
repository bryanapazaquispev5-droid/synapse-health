// ============================================================================
// Archivo: cheatsheet_model.dart
// Propósito: Modelo de datos inmutable para representar chuletas médicas, temas y especialidades clínicas [cheatsheet_model].
// ============================================================================

/// Entidad de datos inmutable y serializable para [CheatsheetModel].
class CheatsheetModel {
  final String id;
  final String areaId;
  final String topicId;
  final String title;
  final String summary;
  final String contentMarkdown;
  final List<String> keyPoints;
  final List<String> mnemonics;
  final int readDurationInMinutes;
  int get readMinutes => readDurationInMinutes;
  final bool isPremium;
  final String sourceBook;

  const CheatsheetModel({
    required this.id,
    required this.areaId,
    required this.topicId,
    required this.title,
    this.summary = '',
    required this.contentMarkdown,
    this.keyPoints = const [],
    this.mnemonics = const [],
    int? readMinutes,
    int? readDurationInMinutes,
    this.isPremium = true,
    this.sourceBook = '',
  }) : readDurationInMinutes = readDurationInMinutes ?? readMinutes ?? 2;

  factory CheatsheetModel.fromMap(Map<String, dynamic> map, String documentId) {
    List<String> parseStringList(dynamic rawList) {
      if (rawList is List) {
        return rawList.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
      }
      return const [];
    }

    int parseReadMinutes(dynamic rawMinutes) {
      if (rawMinutes is int) return rawMinutes;
      if (rawMinutes is num) return rawMinutes.toInt();
      if (rawMinutes != null) return int.tryParse(rawMinutes.toString()) ?? 2;
      return 2;
    }

    return CheatsheetModel(
      id: documentId,
      areaId: map['areaId']?.toString() ?? '',
      topicId: map['topicId']?.toString() ?? '',
      title: map['title']?.toString() ?? map['name']?.toString() ?? '',
      summary: map['summary']?.toString() ?? '',
      contentMarkdown: map['contentMarkdown']?.toString() ?? map['content']?.toString() ?? '',
      keyPoints: parseStringList(map['keyPoints']),
      mnemonics: parseStringList(map['mnemonics']),
      readDurationInMinutes: parseReadMinutes(map['readDurationInMinutes'] ?? map['readMinutes']),
      isPremium: map['isPremium'] == true,
      sourceBook: map['sourceBook']?.toString() ?? map['source']?.toString() ?? map['reference']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'areaId': areaId,
      'topicId': topicId,
      'title': title,
      'summary': summary,
      'contentMarkdown': contentMarkdown,
      'keyPoints': keyPoints,
      'mnemonics': mnemonics,
      'readMinutes': readDurationInMinutes,
      'readDurationInMinutes': readDurationInMinutes,
      'isPremium': isPremium,
      'sourceBook': sourceBook,
    };
  }
}
