import '../../../core/api/aws_api_client.dart';
import '../../auth_login/cognito/api/cognito_auth_service.dart';
import '../../auth_login/cognito/api/cognito_aws_api.dart';
import '../model/academic_history_entry.dart';
import 'aws_history_pages.dart';

/// Explicit Cognito boundary; never switches the existing Firebase repository.
class CognitoHistoryClient {
  CognitoHistoryClient({required this.api, required this.subjectSupplier});
  factory CognitoHistoryClient.withCognito({
    required CognitoAuthService service,
    String baseUrl = const String.fromEnvironment('SYNAPSE_API_BASE_URL'),
    ApiTransport? transport,
  }) => CognitoHistoryClient(
    api: cognitoAwsApi(
      service: service,
      baseUrl: baseUrl,
      transport: transport,
    ),
    subjectSupplier: () => service.currentSession?.sub,
  );
  final AwsApiClient api;
  final String? Function() subjectSupplier;
  bool get isConfigured => api.isConfigured;
  void _requireOwner(String subject) {
    if (subject.isEmpty || subjectSupplier() != subject) {
      throw const AwsApiException(ApiFailure.unauthenticated);
    }
  }

  AwsHistoryPages watchHistory(String subject, {void Function()? onCancel}) {
    _requireOwner(subject);
    return AwsHistoryPages(
      api: api,
      requireOwner: () => _requireOwner(subject),
      mapFailure: (error) => error is AwsApiException
          ? error
          : const AwsApiException(ApiFailure.invalidResponse),
      onCancel: onCancel ?? () {},
    );
  }

  Future<AcademicHistoryEntry> get(String attemptId) async {
    final subject = subjectSupplier();
    if (subject == null) {
      throw const AwsApiException(ApiFailure.unauthenticated);
    }
    _requireOwner(subject);
    final data = await api.fetchHistoryEntry(attemptId);
    _requireOwner(subject);
    try {
      return AcademicHistoryEntry.fromJson(data);
    } catch (_) {
      throw const AwsApiException(ApiFailure.invalidResponse);
    }
  }
}
