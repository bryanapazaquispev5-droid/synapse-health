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
    return TopicModel(
      id: documentId,
      areaId: map['areaId'] ?? '',
      title: map['title'] ?? map['name'] ?? '',
      description: map['description'] ?? '',
      order: (map['order'] is int)
          ? map['order']
          : int.tryParse(map['order']?.toString() ?? '0') ?? 0,
      cheatsheetsCount: map['cheatsheetsCount'] ?? 0,
      quizzesCount: map['quizzesCount'] ?? 0,
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
