import 'dart:convert';

import 'package:synapse_health/features/auth_login/cognito/api/cognito_token_store.dart';
import 'package:synapse_health/features/auth_login/cognito/api/cognito_transport.dart';
import 'package:synapse_health/features/auth_login/cognito/model/cognito_config.dart';

const config = CognitoConfig(
  region: 'us-east-1',
  userPoolId: 'us-east-1_Test',
  clientId: 'test123',
);
final now = DateTime.utc(2026, 10, 12);

class MemoryTokens implements CognitoTokenStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String value) async {
    this.value = value;
  }

  @override
  Future<void> clear() async {
    value = null;
  }
}

class RecordingTransport implements CognitoTransport {
  final calls = <(String, Map<String, dynamic>)>[];
  Future<Map<String, dynamic>> Function(String, Map<String, dynamic>)? respond;
  @override
  Future<Map<String, dynamic>> send(
    String operation,
    Map<String, dynamic> fields,
  ) async {
    calls.add((operation, fields));
    return respond == null
        ? <String, dynamic>{}
        : await respond!(operation, fields);
  }
}

String jwt(Map<String, dynamic> claims, {String algorithm = 'RS256'}) {
  String part(Map<String, dynamic> map) =>
      base64Url.encode(utf8.encode(jsonEncode(map))).replaceAll('=', '');
  return '${part({'alg': algorithm, 'kid': 'fixture'})}.${part(claims)}.c2ln';
}

Map<String, dynamic> tokens({
  bool expired = false,
  String refresh = 'refresh-fixture',
  String sub = 'student',
  String? issuer,
  String? client,
}) {
  final expiry =
      now.add(Duration(seconds: expired ? -60 : 3600)).millisecondsSinceEpoch ~/
      1000;
  final common = {'iss': issuer ?? config.issuer, 'sub': sub, 'exp': expiry};
  return {
    'AccessToken': jwt({
      ...common,
      'token_use': 'access',
      'client_id': client ?? config.clientId,
    }),
    'IdToken': jwt({
      ...common,
      'token_use': 'id',
      'aud': client ?? config.clientId,
      'email': 'local@example.test',
      'name': 'Local test',
    }),
    'RefreshToken': refresh,
  };
}
