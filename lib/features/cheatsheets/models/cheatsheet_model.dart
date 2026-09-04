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
    List<String> parseList(dynamic val) {
      if (val is List) {
        return val.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
      }
      return [];
    }

    int parseMinutes(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val != null) return int.tryParse(val.toString()) ?? 2;
      return 2;
    }

    return CheatsheetModel(
      id: documentId,
      areaId: map['areaId']?.toString() ?? '',
      topicId: map['topicId']?.toString() ?? '',
      title: map['title']?.toString() ?? map['name']?.toString() ?? '',
      summary: map['summary']?.toString() ?? '',
      contentMarkdown: map['contentMarkdown']?.toString() ?? map['content']?.toString() ?? '',
      keyPoints: parseList(map['keyPoints']),
      mnemonics: parseList(map['mnemonics']),
      readMinutes: parseMinutes(map['readMinutes']),
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
      'readMinutes': readMinutes,
      'isPremium': isPremium,
      'sourceBook': sourceBook,
    };
  }
}
