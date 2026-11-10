import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/auth/dynamo_auth_service.dart';
import 'package:synapse_health/features/auth_login/cognito/model/cognito_auth_exception.dart';

class FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> data = {};

  @override
  Future<String?> read({required String key, AppleOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WebOptions? webOptions, AppleOptions? mOptions, WindowsOptions? wOptions}) async => data[key];

  @override
  Future<void> write({required String key, required String? value, AppleOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WebOptions? webOptions, AppleOptions? mOptions, WindowsOptions? wOptions}) async {
    if (value != null) data[key] = value;
  }

  @override
  Future<void> delete({required String key, AppleOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WebOptions? webOptions, AppleOptions? mOptions, WindowsOptions? wOptions}) async {
    data.remove(key);
  }
}

class FakeHttpClient extends Fake implements HttpClient {
  FakeHttpClient({required this.handler});
  final Future<FakeHttpResponse> Function(Uri uri, String method, String body) handler;
  @override
  Duration? connectionTimeout;

  @override
  Future<HttpClientRequest> postUrl(Uri url) async => FakeHttpRequest(uri: url, method: 'POST', handler: handler);

  @override
  void close({bool force = false}) {}
}

class FakeHttpRequest extends Fake implements HttpClientRequest {
  FakeHttpRequest({required this.uri, required this.method, required this.handler});
  @override
  final Uri uri;
  @override
  final String method;
  final Future<FakeHttpResponse> Function(Uri uri, String method, String body) handler;
  final StringBuffer _buffer = StringBuffer();
  final Map<String, String> headersMap = {};

  @override
  HttpHeaders get headers => FakeHttpHeaders(headersMap);

  @override
  void write(Object? obj) => _buffer.write(obj);

  @override
  Future<HttpClientResponse> close() => handler(uri, method, _buffer.toString());
}

class FakeHttpHeaders extends Fake implements HttpHeaders {
  FakeHttpHeaders(this.map);
  final Map<String, String> map;
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) => map[name] = value.toString();
}

class FakeHttpResponse extends Stream<List<int>> implements HttpClientResponse {
  FakeHttpResponse({required this.statusCode, required this.body});
  @override
  final int statusCode;
  final String body;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData, {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream.value(utf8.encode(body)).listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  String createTestJwt(String sub, String email, int exp) {
    final header = base64Url.encode(utf8.encode('{"alg":"HS256","typ":"JWT"}')).replaceAll('=', '');
    final payload = base64Url.encode(utf8.encode('{"sub":"$sub","email":"$email","exp":$exp}')).replaceAll('=', '');
    return '$header.$payload.fake_signature';
  }

  test('register sends correct JSON and stores session', () async {
    final storage = FakeSecureStorage();
    final exp = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
    final token = createTestJwt('user-123', 'student@test.com', exp);

    final service = DynamoAuthService(
      baseUrl: 'https://api.test',
      storage: storage,
      clientFactory: () => FakeHttpClient(handler: (uri, method, body) async {
        expect(uri.path, '/api/v1/auth/register');
        final json = jsonDecode(body) as Map<String, dynamic>;
        expect(json['email'], 'student@test.com');
        expect(json['career'], 'General Medicine');
        return FakeHttpResponse(statusCode: 200, body: jsonEncode({
          'data': {
            'token': token,
            'user': {
              'sub': 'user-123',
              'email': 'student@test.com',
              'name': 'Student Name',
              'career': 'General Medicine',
              'gender': 'Male',
            }
          }
        }));
      }),
    );

    final cred = await service.register(
      name: 'Student Name',
      email: 'student@test.com',
      password: 'Password123!',
      career: 'General Medicine',
      gender: 'Male',
    );

    expect(cred.user?.uid, 'user-123');
    expect(cred.user?.email, 'student@test.com');
    expect(await service.accessToken(), token);
    expect(storage.data.containsKey('synapse.dynamo_auth.session.v1'), isTrue);
  });

  test('signIn verifies credentials and restores active session', () async {
    final storage = FakeSecureStorage();
    final exp = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
    final token = createTestJwt('user-456', 'login@test.com', exp);

    final service = DynamoAuthService(
      baseUrl: 'https://api.test',
      storage: storage,
      clientFactory: () => FakeHttpClient(handler: (uri, method, body) async {
        expect(uri.path, '/api/v1/auth/login');
        return FakeHttpResponse(statusCode: 200, body: jsonEncode({
          'data': {
            'token': token,
            'user': {
              'sub': 'user-456',
              'email': 'login@test.com',
              'name': 'Login User',
            }
          }
        }));
      }),
    );

    final cred = await service.signIn(email: 'login@test.com', password: 'Password123!');
    expect(cred.user?.uid, 'user-456');
    expect(service.currentUser?.email, 'login@test.com');

    // Test session restoration on app boot
    final freshService = DynamoAuthService(baseUrl: 'https://api.test', storage: storage);
    await freshService.initialize();
    expect(freshService.currentUser?.uid, 'user-456');
    expect(freshService.currentUser?.email, 'login@test.com');
  });

  test('signIn maps 401 response to authentication_failed exception', () async {
    final service = DynamoAuthService(
      baseUrl: 'https://api.test',
      storage: FakeSecureStorage(),
      clientFactory: () => FakeHttpClient(handler: (uri, method, body) async {
        return FakeHttpResponse(statusCode: 401, body: jsonEncode({'message': 'Invalid email or password.'}));
      }),
    );

    expect(
      () => service.signIn(email: 'wrong@test.com', password: 'bad'),
      throwsA(isA<CognitoAuthException>().having((e) => e.code, 'code', 'authentication_failed')),
    );
  });
}
