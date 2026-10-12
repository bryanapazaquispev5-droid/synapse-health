import '../../../core/api/aws_api_client.dart';
import '../../auth_login/cognito/api/cognito_auth_service.dart';
import '../../auth_login/cognito/api/cognito_aws_api.dart';
import '../../quizzes/model/quiz_topic_progress_model.dart';

class AwsProgressPage {
  const AwsProgressPage({required this.items, this.nextCursor});
  final List<QuizTopicProgressModel> items;
  final String? nextCursor;
}

/// Each page contains canonical topic records; totals require every page.
class AwsProgressClient {
  AwsProgressClient({required this.api});
  factory AwsProgressClient.withCognito({
    required CognitoAuthService service,
    String baseUrl = const String.fromEnvironment('SYNAPSE_API_BASE_URL'),
    ApiTransport? transport,
  }) => AwsProgressClient(
    api: cognitoAwsApi(
      service: service,
      baseUrl: baseUrl,
      transport: transport,
    ),
  );
  final AwsApiClient api;
  bool get isConfigured => api.isConfigured;
  Future<AwsProgressPage> list({int limit = 20, String? cursor}) async {
    if (limit < 1 || limit > 50) throw ArgumentError('Invalid page limit.');
    final data = await api.requestData(
      'GET',
      'api/v1/progress/me',
      query: {'limit': '$limit', 'cursor': ?cursor},
    );
    try {
      final items = (data['items'] as List)
          .map((item) => parseTopic(Map<String, dynamic>.from(item as Map)))
          .toList();
      return AwsProgressPage(
        items: List.unmodifiable(items),
        nextCursor: data['nextCursor'] as String?,
      );
    } catch (_) {
      throw const AwsApiException(ApiFailure.invalidResponse);
    }
  }

  static QuizTopicProgressModel parseTopic(Map<String, dynamic> item) {
    for (final field in ['areaId', 'topicId']) {
      if (item[field] is! String || (item[field] as String).isEmpty) {
        throw const FormatException('Invalid topic.');
      }
    }
    if (item['currentAttemptNumber'] is! int ||
        (item['currentAttemptNumber'] as int) < 1) {
      throw const FormatException('Invalid attempt.');
    }
    DateTime.parse(item['updatedAt'] as String);
    void validateAttempt(Map attempt) {
      DateTime.parse(attempt['startedAt'] as String);
      if (attempt['completedAt'] != null) {
        DateTime.parse(attempt['completedAt'] as String);
      }
      for (final field in [
        'attemptNumber',
        'totalEarnedStars',
        'totalMaxStars',
      ]) {
        if (attempt[field] is! int || (attempt[field] as int) < 0) {
          throw const FormatException('Invalid attempt.');
        }
      }
      if ((attempt['attemptNumber'] as int) < 1 ||
          (attempt['totalEarnedStars'] as int) >
              (attempt['totalMaxStars'] as int)) {
        throw const FormatException('Invalid stars.');
      }
      for (final raw in (attempt['questionAnswers'] as Map).values) {
        final answer = raw as Map;
        if (answer['isAnswered'] != true ||
            answer['isCorrect'] is! bool ||
            answer['earnedStars'] is! int ||
            answer['maxStars'] is! int ||
            (answer['earnedStars'] as int) < 0 ||
            (answer['maxStars'] as int) < 1 ||
            (answer['earnedStars'] as int) > (answer['maxStars'] as int)) {
          throw const FormatException('Invalid answer.');
        }
        DateTime.parse(answer['answeredAt'] as String);
      }
    }

    validateAttempt(item['activeAttempt'] as Map);
    final history = item['history'] as List;
    if (history.length > 3) throw const FormatException('Invalid history.');
    for (final attempt in history) {
      validateAttempt(attempt as Map);
    }
    return QuizTopicProgressModel.fromMap(item);
  }
}
