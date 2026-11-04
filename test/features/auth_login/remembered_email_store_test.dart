import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/features/auth_login/api/remembered_email_store.dart';

class FakeEmailStorage implements RememberedEmailStorage {
  String? email;
  @override
  Future<String?> read() async => email;
  @override
  Future<void> write(String value) async {
    email = value;
  }

  @override
  Future<void> delete() async {
    email = null;
  }
}

void main() {
  late RememberedEmailStore store;
  late FakeEmailStorage storage;
  setUp(() {
    storage = FakeEmailStorage();
    store = RememberedEmailStore(storage: storage);
  });

  test('stores a trimmed email and removes it when disabled', () async {
    await store.save('  student@example.test  ');
    expect(await store.load(), 'student@example.test');
    await store.save(null);
    expect(await store.load(), isNull);
  });

  test('does not retain an empty email', () async {
    await store.save('  ');
    expect(await store.load(), isNull);
  });
}
