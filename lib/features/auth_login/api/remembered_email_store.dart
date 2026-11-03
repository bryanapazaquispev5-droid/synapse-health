import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class RememberedEmailStorage {
  Future<String?> read();
  Future<void> write(String email);
  Future<void> delete();
}

class _SecureRememberedEmailStorage implements RememberedEmailStorage {
  const _SecureRememberedEmailStorage();
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.unlocked_this_device,
    ),
  );
  static const _key = 'synapse.remembered_login_email.v1';

  @override
  Future<String?> read() => _storage.read(key: _key);
  @override
  Future<void> write(String email) => _storage.write(key: _key, value: email);
  @override
  Future<void> delete() => _storage.delete(key: _key);
}

class RememberedEmailStore {
  RememberedEmailStore({RememberedEmailStorage? storage})
    : _storage = storage ?? const _SecureRememberedEmailStorage();
  final RememberedEmailStorage _storage;

  Future<String?> load() async {
    final email = (await _storage.read())?.trim();
    return email?.isEmpty == true ? null : email;
  }

  Future<void> save(String? email) async {
    final value = email?.trim();
    if (value == null || value.isEmpty) {
      await _storage.delete();
      return;
    }
    await _storage.write(value);
  }
}
