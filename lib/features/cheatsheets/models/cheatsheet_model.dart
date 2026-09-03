class CheatsheetModel {
  final String id;
  final String areaId;
  final String topicId;
  final String title;
  final String summary;
  final String contentMarkdown;
  final List<String> keyPoints;
  final List<String> mnemonics;
  final int readMinutes;
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
    this.readMinutes = 2,
    this.isPremium = true,
    this.sourceBook = '',
  });

  factory CheatsheetModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CheatsheetModel(
      id: documentId,
      areaId: map['areaId'] ?? '',
      topicId: map['topicId'] ?? '',
      title: map['title'] ?? '',
      summary: map['summary'] ?? '',
      contentMarkdown: map['contentMarkdown'] ?? '',
      keyPoints: List<String>.from(map['keyPoints'] ?? []),
      mnemonics: List<String>.from(map['mnemonics'] ?? []),
      readMinutes: map['readMinutes'] ?? 2,
      isPremium: map['isPremium'] ?? true,
      sourceBook: map['sourceBook'] ?? map['source'] ?? map['reference'] ?? '',
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
      'readMinutes': readMinutes,
      'isPremium': isPremium,
      'sourceBook': sourceBook,
    };
  }
}
