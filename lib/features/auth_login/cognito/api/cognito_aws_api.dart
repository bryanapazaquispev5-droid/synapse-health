import '../../../../core/api/aws_api_client.dart';
import '../model/cognito_auth_exception.dart';
import 'cognito_auth_service.dart';

AwsApiClient cognitoAwsApi({
  required CognitoAuthService service,
  String baseUrl = const String.fromEnvironment('SYNAPSE_API_BASE_URL'),
  ApiTransport? transport,
}) => AwsApiClient(
  baseUrl: baseUrl,
  tokenSupplier: (refresh) => cognitoAwsToken(service, refresh),
  sessionUidSupplier: () => service.currentSession?.sub,
  transport: transport,
);

Future<String?> cognitoAwsToken(
  CognitoAuthService service,
  bool refresh,
) async {
  try {
    return (await service.validSession(forceRefresh: refresh))?.accessToken;
  } on CognitoAuthException catch (error) {
    throw AwsApiException(switch (error.code) {
      'offline' => ApiFailure.offline,
      'timeout' => ApiFailure.timeout,
      'rate_limited' => ApiFailure.rateLimited,
      'service_unavailable' => ApiFailure.unavailable,
      _ => ApiFailure.unauthenticated,
    });
  }
}
