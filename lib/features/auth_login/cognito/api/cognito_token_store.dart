import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class CognitoTokenStore {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> clear();
}

class SecureCognitoTokenStore implements CognitoTokenStore {
  SecureCognitoTokenStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(resetOnError: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.unlocked_this_device,
            ),
          );
  final FlutterSecureStorage _storage;
  static const _key = 'synapse.cognito.session.v1';
  @override
  Future<String?> read() => _storage.read(key: _key);
  @override
  Future<void> write(String value) => _storage.write(key: _key, value: value);
  @override
  Future<void> clear() => _storage.delete(key: _key);
}
