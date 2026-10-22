import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/api/aws_api_client.dart';
import 'package:synapse_health/features/auth_login/cognito/api/cognito_auth_service.dart';
import 'package:synapse_health/features/auth_login/cognito/model/cognito_auth_exception.dart';
import 'package:synapse_health/features/auth_login/cognito/model/cognito_session.dart';
import 'package:synapse_health/features/cheatsheets/api/aws_flashcards_client.dart';

class FailedRefresh extends Fake implements CognitoAuthService {
  FailedRefresh(this.code);
  final String code;
  @override
  CognitoSession get currentSession => CognitoSession(
    sub: 'fixture-sub',
    accessToken: 'fixture-token',
    idToken: 'fixture-id',
    refreshToken: 'fixture-refresh',
    expiresAt: DateTime.utc(2020),
  );
  @override
  Future<CognitoSession?> validSession({bool forceRefresh = false}) async =>
      throw CognitoAuthException(code, 'Internal test fixture');
}

void main() {
  final cases = {
    'offline': ApiFailure.offline,
    'timeout': ApiFailure.timeout,
    'rate_limited': ApiFailure.rateLimited,
    'service_unavailable': ApiFailure.unavailable,
    'invalid_session': ApiFailure.unauthenticated,
  };
  for (final entry in cases.entries) {
    test('Cognito ${entry.key} maps to safe API category', () async {
      final api = AwsFlashcardsClient.withCognito(
        service: FailedRefresh(entry.key),
        baseUrl: 'https://api.example.test',
        transport: (_, _, _, _) => throw StateError('not called'),
      );
      await expectLater(
        api.list(areaId: 'area'),
        throwsA(
          isA<AwsApiException>().having(
            (error) => error.failure,
            'failure',
            entry.value,
          ),
        ),
      );
    });
  }
}
