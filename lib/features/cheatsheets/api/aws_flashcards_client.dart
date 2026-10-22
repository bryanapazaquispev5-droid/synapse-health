import '../../../core/api/aws_api_client.dart';
import '../../auth_login/cognito/api/cognito_auth_service.dart';
import '../../auth_login/cognito/api/cognito_aws_api.dart';
import '../model/aws_flashcard.dart';
import '../model/cheatsheet_model.dart';

/// Prepared AWS adapter. Existing Firestore screens remain the active source.
class AwsFlashcardsClient {
  AwsFlashcardsClient({required this.api});

  factory AwsFlashcardsClient.withCognito({
    required CognitoAuthService service,
    String baseUrl = const String.fromEnvironment('SYNAPSE_API_BASE_URL'),
    ApiTransport? transport,
  }) => AwsFlashcardsClient(
    api: cognitoAwsApi(
      service: service,
      baseUrl: baseUrl,
      transport: transport,
    ),
  );

  final AwsApiClient api;
  static const _path = 'api/v1/flashcards';
  bool get isConfigured => api.isConfigured;

  Future<AwsFlashcardPage> list({
    required String areaId,
    String? topicId,
    int limit = 20,
    String? cursor,
  }) async {
    if (limit < 1 || limit > 50) {
      throw ArgumentError.value(limit, 'limit');
    }
    final data = await api.requestData(
      'GET',
      _path,
      query: {
        'limit': '$limit',
        'areaId': areaId,
        'topicId': ?topicId,
        'cursor': ?cursor,
      },
    );
    try {
      final items = data['items'] as List;
      return AwsFlashcardPage(
        items: List.unmodifiable(
          items.map(
            (item) =>
                AwsFlashcard.fromMap(Map<String, dynamic>.from(item as Map)),
          ),
        ),
        nextCursor: data['nextCursor'] as String?,
      );
    } catch (_) {
      throw const AwsApiException(ApiFailure.invalidResponse);
    }
  }

  Future<AwsFlashcard> get(String id) async =>
      _decode(await api.requestData('GET', _itemPath(id)));

  Future<AwsFlashcard> create(CheatsheetModel input) async {
    final body = input.toMap()..remove('readMinutes');
    return _decode(await api.requestData('POST', _path, body: body));
  }

  Future<AwsFlashcard> update({
    required String id,
    required int version,
    required Map<String, dynamic> changes,
  }) async => _decode(
    await api.requestData(
      'PATCH',
      _itemPath(id),
      body: changes,
      extraHeaders: _versionHeader(version),
    ),
  );

  Future<void> delete({required String id, required int version}) async {
    await api.requestData(
      'DELETE',
      _itemPath(id),
      extraHeaders: _versionHeader(version),
    );
  }

  String _itemPath(String id) {
    if (!RegExp(r'^[A-Za-z0-9_-]{1,2048}$').hasMatch(id)) {
      throw ArgumentError.value(id, 'id');
    }
    return '$_path/$id';
  }

  Map<String, String> _versionHeader(int version) {
    if (version < 1) throw ArgumentError.value(version, 'version');
    return {'If-Match': '"$version"'};
  }

  AwsFlashcard _decode(Map<String, dynamic> data) {
    try {
      return AwsFlashcard.fromMap(data);
    } catch (_) {
      throw const AwsApiException(ApiFailure.invalidResponse);
    }
  }
}
