class TopicModel {
  final String id;
  final String areaId;
  final String title;
  final String description;
  final int order;
  final int cheatsheetsCount;
  final int quizzesCount;

  const TopicModel({
    required this.id,
    required this.areaId,
    required this.title,
    this.description = '',
    required this.order,
    this.cheatsheetsCount = 0,
    this.quizzesCount = 0,
  });

  factory TopicModel.fromMap(Map<String, dynamic> map, String documentId) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val != null) return int.tryParse(val.toString()) ?? 0;
      return 0;
    }

    return TopicModel(
      id: documentId,
      areaId: map['areaId']?.toString() ?? '',
      title: map['title']?.toString() ?? map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      order: parseInt(map['order']),
      cheatsheetsCount: parseInt(map['cheatsheetsCount'] ?? map['totalCheatsheets']),
      quizzesCount: parseInt(map['quizzesCount']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'areaId': areaId,
      'title': title,
      'description': description,
      'order': order,
      'cheatsheetsCount': cheatsheetsCount,
      'quizzesCount': quizzesCount,
    };
  }
}
