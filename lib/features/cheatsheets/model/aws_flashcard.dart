import 'cheatsheet_model.dart';

/// Versioned AWS representation; presentation reuses the existing catalog model.
class AwsFlashcard {
  const AwsFlashcard({
    required this.cheatsheet,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  final CheatsheetModel cheatsheet;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory AwsFlashcard.fromMap(Map<String, dynamic> data) {
    final id = data['id'];
    final version = data['version'];
    if (id is! String || id.isEmpty || version is! int || version < 1) {
      throw const FormatException('Invalid flashcard metadata.');
    }
    return AwsFlashcard(
      cheatsheet: CheatsheetModel.fromMap(data, id),
      version: version,
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    );
  }
}

class AwsFlashcardPage {
  const AwsFlashcardPage({required this.items, this.nextCursor});

  final List<AwsFlashcard> items;
  final String? nextCursor;
}
