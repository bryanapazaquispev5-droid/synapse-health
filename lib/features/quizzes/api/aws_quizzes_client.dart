import '../../../core/api/aws_api_client.dart';
import '../../auth_login/cognito/api/cognito_auth_service.dart';
import '../../auth_login/cognito/api/cognito_aws_api.dart';
import '../model/aws_quiz.dart';
import '../../personal_progress/api/aws_progress_client.dart';
import '../model/quiz_topic_progress_model.dart';

/// Prepared Cognito adapter; the existing Firebase quiz flow stays active.
class AwsQuizzesClient {
  AwsQuizzesClient({required this.api});
  factory AwsQuizzesClient.withCognito({
    required CognitoAuthService service,
    String baseUrl = const String.fromEnvironment('SYNAPSE_API_BASE_URL'),
    ApiTransport? transport,
  }) => AwsQuizzesClient(
    api: cognitoAwsApi(
      service: service,
      baseUrl: baseUrl,
      transport: transport,
    ),
  );
  final AwsApiClient api;
  bool get isConfigured => api.isConfigured;
  static const _path = 'api/v1/quizzes';
  Future<AwsQuizPage> list({
    required String areaId,
    String? topicId,
    int limit = 20,
    String? cursor,
  }) async {
    _id(areaId);
    if (topicId != null) _id(topicId);
    if (limit < 1 || limit > 50) throw ArgumentError('Invalid page limit.');
    final data = await api.requestData(
      'GET',
      _path,
      query: {
        'areaId': areaId,
        'topicId': ?topicId,
        'limit': '$limit',
        'cursor': ?cursor,
      },
    );
    return _decode(
      () => AwsQuizPage(
        List.unmodifiable(
          (data['items'] as List).map(
            (item) => AwsQuiz(Map<String, dynamic>.from(item as Map)),
          ),
        ),
        data['nextCursor'] as String?,
      ),
    );
  }

  Future<AwsQuiz> get(String id) async {
    _id(id);
    final data = await api.requestData('GET', '$_path/$id');
    return _decode(() => AwsQuiz(data));
  }

  Future<AwsQuizStart> start(
    String quizId, {
    required String idempotencyKey,
  }) async {
    _id(quizId);
    final data = await api.requestData(
      'POST',
      '$_path/$quizId/attempts/start',
      body: {},
      extraHeaders: {'Idempotency-Key': idempotencyKey},
    );
    return _decode(() => _attempt(data));
  }

  Future<AwsQuizResult> submit(
    String quizId, {
    required String attemptId,
    required AwsQuizAnswer answer,
  }) async {
    _id(quizId);
    _id(attemptId);
    final data = await api.requestData(
      'POST',
      '$_path/$quizId/attempts',
      body: {'attemptId': attemptId, 'answer': answer.toMap()},
    );
    return _decode(() => AwsQuizResult(data));
  }

  Future<AwsQuizStart> getAttempt(String quizId, String attemptId) async {
    _id(quizId);
    _id(attemptId);
    final data = await api.requestData(
      'GET',
      '$_path/$quizId/attempts/$attemptId',
    );
    return _decode(() => _attempt(data));
  }

  Future<QuizTopicProgressModel> retryTopic({
    required String areaId,
    required String topicId,
    required int expectedAttemptNumber,
    required String idempotencyKey,
  }) async {
    _id(areaId);
    _id(topicId);
    if (expectedAttemptNumber < 1) {
      throw ArgumentError('Invalid attempt number.');
    }
    final data = await api.requestData(
      'POST',
      '$_path/topics/$topicId/retry',
      body: {'areaId': areaId, 'expectedAttemptNumber': expectedAttemptNumber},
      extraHeaders: {'Idempotency-Key': idempotencyKey},
    );
    return _decode(() => AwsProgressClient.parseTopic(data));
  }

  static AwsQuizStart _attempt(Map<String, dynamic> data) {
    if (!{'started', 'submitted'}.contains(data['status']) ||
        data['attemptId'] is! String ||
        (data['attemptId'] as String).isEmpty ||
        (data['status'] == 'submitted' && data['result'] == null) ||
        (data['topicAttemptNumber'] as int) < 1) {
      throw const FormatException('Invalid attempt.');
    }
    return AwsQuizStart(
      attemptId: data['attemptId'] as String,
      startedAt: DateTime.parse(data['startedAt'] as String),
      topicAttemptNumber: data['topicAttemptNumber'] as int,
      question: AwsQuiz(Map<String, dynamic>.from(data['question'] as Map)),
      status: data['status'] as String,
      result: data['result'] == null
          ? null
          : AwsQuizResult(Map<String, dynamic>.from(data['result'] as Map)),
    );
  }

  static void _id(String value) {
    if (!RegExp(r'^[A-Za-z0-9_-]{1,2048}$').hasMatch(value)) {
      throw ArgumentError('Invalid identifier.');
    }
  }

  static T _decode<T>(T Function() parse) {
    try {
      return parse();
    } catch (_) {
      throw const AwsApiException(ApiFailure.invalidResponse);
    }
  }
}
