typedef ApiTokenSupplier = Future<String?> Function(bool forceRefresh);
typedef ApiTransport = Future<ApiResponse> Function(
  Uri uri,
  Map<String, String> headers,
  String method,
  String? body,
);

class ApiResponse {
  const ApiResponse(this.statusCode, this.body);

  final int statusCode;
  final String body;
}

enum ApiFailure {
  disabled,
  unauthenticated,
  forbidden,
  notFound,
  rateLimited,
  unavailable,
  offline,
  timeout,
  invalidResponse,
}

/// Carries a safe category, never response bodies, tokens or internal errors.
class AwsApiException implements Exception {
  const AwsApiException(this.failure);

  final ApiFailure failure;
}
