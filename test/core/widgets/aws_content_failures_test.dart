import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/api/aws_api_client.dart';
import 'package:synapse_health/core/auth/app_auth.dart';
import 'package:synapse_health/core/widgets/states/app_async_content.dart';

void main() {
  for (final failure in [ApiFailure.unauthenticated, ApiFailure.forbidden]) {
    test('AWS $failure invalidates private retained content', () {
      final error = AwsApiException(failure);
      expect(isContentAccessFailure(error), isTrue);
      expect(safeContentError(error, 'fallback'), isNot('fallback'));
    });
  }
  test('expired Cognito identity invalidates private retained content', () {
    const error = AppAuthException(
      'unauthenticated',
      'Synthetic private detail',
    );
    expect(isContentAccessFailure(error), isTrue);
    expect(
      safeContentError(error, 'fallback'),
      isNot('Synthetic private detail'),
    );
  });
  for (final failure in [ApiFailure.offline, ApiFailure.timeout]) {
    test('AWS $failure displays an offline category', () {
      expect(isNetworkFailure(AwsApiException(failure)), isTrue);
    });
  }
  test('AWS internal failures keep a safe generic message', () {
    const error = AwsApiException(ApiFailure.unavailable);
    expect(isContentAccessFailure(error), isFalse);
    expect(safeContentError(error, 'safe fallback'), 'safe fallback');
  });
}
