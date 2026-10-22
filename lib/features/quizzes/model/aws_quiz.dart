/// Public AWS questions deliberately cannot be converted to answer-bearing QuizModel.
class AwsQuiz {
  AwsQuiz(Map<String, dynamic> data) {
    if (data.keys.any(
      (key) => {
        'correctIndex',
        'rationale',
        'matchingPairs',
        'orderingItems',
      }.contains(key),
    )) {
      throw const FormatException('Unsafe question response.');
    }
    id = _text(data, 'id');
    areaId = _text(data, 'areaId');
    topicId = _text(data, 'topicId');
    type = _text(data, 'type');
    question = _text(data, 'question');
    sourceBook = data['sourceBook'] as String;
    orderIndex = data['orderIndex'] as int;
    if (!{'single_choice', 'matching', 'ordering'}.contains(type)) {
      throw const FormatException('Invalid question type.');
    }
    options = _choices(data, 'options');
    leftItems = _choices(data, 'leftItems');
    rightItems = _choices(data, 'rightItems');
    items = _choices(data, 'items');
    if (type == 'single_choice' && options.isEmpty ||
        type == 'matching' &&
            (leftItems.isEmpty || leftItems.length != rightItems.length) ||
        type == 'ordering' && items.isEmpty) {
      throw const FormatException('Incomplete question.');
    }
  }
  late final String id, areaId, topicId, type, question, sourceBook;
  late final int orderIndex;
  late final List<AwsQuizChoice> options, leftItems, rightItems, items;
  static String _text(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is! String || value.isEmpty) {
      throw const FormatException('Invalid question field.');
    }
    return value;
  }

  static List<AwsQuizChoice> _choices(Map<String, dynamic> data, String key) {
    if (!data.containsKey(key)) return const [];
    final values = data[key] as List;
    final result = values.map((value) {
      final map = Map<String, dynamic>.from(value as Map);
      return AwsQuizChoice(id: _text(map, 'id'), text: _text(map, 'text'));
    }).toList();
    if (result.map((choice) => choice.id).toSet().length != result.length) {
      throw const FormatException('Duplicate choice.');
    }
    return List.unmodifiable(result);
  }
}

class AwsQuizChoice {
  const AwsQuizChoice({required this.id, required this.text});
  final String id, text;
}

class AwsQuizPage {
  const AwsQuizPage(this.items, this.nextCursor);
  final List<AwsQuiz> items;
  final String? nextCursor;
}

class AwsQuizStart {
  const AwsQuizStart({
    required this.attemptId,
    required this.startedAt,
    required this.topicAttemptNumber,
    required this.question,
    required this.status,
    this.result,
  });
  final String attemptId;
  final DateTime startedAt;
  final int topicAttemptNumber;
  final AwsQuiz question;
  final String status;
  final AwsQuizResult? result;
}

class AwsQuizResult {
  AwsQuizResult(Map<String, dynamic> data)
    : attemptId = data['attemptId'] as String,
      quizId = data['quizId'] as String,
      answeredAt = DateTime.parse(data['answeredAt'] as String),
      durationSeconds = data['durationSeconds'] as int,
      topicAttemptNumber = data['topicAttemptNumber'] as int,
      isCorrect = data['isCorrect'] as bool,
      score = data['score'] as int,
      earnedStars = data['earnedStars'] as int,
      maxStars = data['maxStars'] as int {
    if (attemptId.isEmpty ||
        quizId.isEmpty ||
        durationSeconds < 0 ||
        topicAttemptNumber < 1 ||
        earnedStars < 0 ||
        maxStars < 1 ||
        earnedStars > maxStars ||
        !{0, 1}.contains(score) ||
        score != (isCorrect ? 1 : 0)) {
      throw const FormatException('Invalid quiz result.');
    }
  }
  final String attemptId, quizId;
  final DateTime answeredAt;
  final int durationSeconds, topicAttemptNumber, score, earnedStars, maxStars;
  final bool isCorrect;
}

sealed class AwsQuizAnswer {
  const AwsQuizAnswer();
  Map<String, dynamic> toMap();
}

class AwsChoiceAnswer extends AwsQuizAnswer {
  const AwsChoiceAnswer(this.choiceId);
  final String choiceId;
  @override
  Map<String, dynamic> toMap() => {'choiceId': choiceId};
}

class AwsMatchingAnswer extends AwsQuizAnswer {
  const AwsMatchingAnswer(this.pairs);
  final List<({String leftId, String rightId})> pairs;
  @override
  Map<String, dynamic> toMap() => {
    'pairs': pairs
        .map((pair) => {'leftId': pair.leftId, 'rightId': pair.rightId})
        .toList(),
  };
}

class AwsOrderingAnswer extends AwsQuizAnswer {
  const AwsOrderingAnswer(this.itemIds);
  final List<String> itemIds;
  @override
  Map<String, dynamic> toMap() => {'itemIds': itemIds};
}
