import '../../../core/api/aws_api_client.dart';
import '../../auth_login/cognito/api/cognito_auth_service.dart';
import '../../auth_login/cognito/api/cognito_aws_api.dart';
import '../model/aws_ranking_entry.dart';

/// Explicit prepared adapter; positions and scores are never calculated here.
class AwsRankingClient {
  AwsRankingClient({required this.api});
  factory AwsRankingClient.withCognito({
    required CognitoAuthService service,
    String baseUrl = const String.fromEnvironment('SYNAPSE_API_BASE_URL'),
    ApiTransport? transport,
  }) => AwsRankingClient(
    api: cognitoAwsApi(
      service: service,
      baseUrl: baseUrl,
      transport: transport,
    ),
  );
  final AwsApiClient api;
  bool get isConfigured => api.isConfigured;
  Future<AwsRankingPage> list({int limit = 20, String? cursor}) async {
    if (limit < 1 || limit > 50) throw ArgumentError('Invalid page limit.');
    final data = await api.requestData(
      'GET',
      'api/v1/ranking',
      query: {'limit': '$limit', 'cursor': ?cursor},
    );
    return _decode(() {
      final items = (data['items'] as List)
          .map(
            (item) => AwsRankingEntry(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
      if (items.map((item) => item.publicId).toSet().length != items.length ||
          items.map((item) => item.rank).toSet().length != items.length) {
        throw const FormatException('Duplicate ranking entry.');
      }
      for (var index = 1; index < items.length; index++) {
        if (items[index].rank <= items[index - 1].rank) {
          throw const FormatException('Invalid position order.');
        }
      }
      return AwsRankingPage(
        items: List.unmodifiable(items),
        nextCursor: data['nextCursor'] as String?,
      );
    });
  }

  Future<AwsRankingEntry?> me() async {
    final data = await api.requestData('GET', 'api/v1/ranking/me');
    if (!data.containsKey('entry')) {
      throw const AwsApiException(ApiFailure.invalidResponse);
    }
    return _decode(
      () => data['entry'] == null
          ? null
          : AwsRankingEntry(Map<String, dynamic>.from(data['entry'] as Map)),
    );
  }

  static T _decode<T>(T Function() parse) {
    try {
      return parse();
    } catch (_) {
      throw const AwsApiException(ApiFailure.invalidResponse);
    }
  }
}
