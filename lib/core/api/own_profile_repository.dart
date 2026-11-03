import '../auth/app_auth.dart';
import 'aws_data_source.dart';

class ProfileRecord {
  const ProfileRecord(this._data);
  final Map<String, dynamic>? _data;
  bool get exists => _data != null && _data.isNotEmpty;
  Map<String, dynamic>? data() => _data;
}

class OwnProfileRepository {
  OwnProfileRepository({AwsDataSource? source})
    : source = source ?? AwsDataSource.instance;
  final AwsDataSource source;
  static const path = 'v1/me/profile';

  void requireOwner(String uid) {
    if (AppAuth.instance.currentUser?.uid != uid) {
      throw const AppAuthException('unauthenticated', 'Sign in.');
    }
  }

  Stream<ProfileRecord> watch(String uid) {
    requireOwner(uid);
    return source.watch(path).map((data) {
      requireOwner(uid);
      return ProfileRecord(data);
    });
  }

  Future<Map<String, dynamic>> fetch(String uid) async {
    requireOwner(uid);
    final data = await source.api.fetchOwnProfile();
    requireOwner(uid);
    return data;
  }

  Future<void> save(
    String uid, {
    required String name,
    required String career,
    required String gender,
  }) async {
    requireOwner(uid);
    await source.mutate('PUT', path, {
      'name': name.trim(),
      'career': career.trim(),
      'gender': gender,
    });
    requireOwner(uid);
  }

  Future<void> update(String uid, String field, String value) async {
    requireOwner(uid);
    await source.mutate('PATCH', path, {field: value.trim()});
    requireOwner(uid);
  }
}
