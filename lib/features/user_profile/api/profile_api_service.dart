import '../../../core/auth/app_auth.dart';
import '../../../core/api/own_profile_repository.dart';
import '../../../core/services/user_local_profile_service.dart';

export '../../../core/api/own_profile_repository.dart' show ProfileRecord;

class ProfileApiService {
  final _profiles = OwnProfileRepository();
  Stream<ProfileRecord> getUserProfileStream(String uid) =>
      _profiles.watch(uid);

  Future<void> updateName({
    required AppUser user,
    required String newName,
    required LocalUserProfile? localProfile,
  }) async {
    await _profiles.update(user.uid, 'name', newName);
    await user.updateDisplayName(newName);
    await _cache(
      user,
      name: newName,
      career: localProfile?.career,
      gender: localProfile?.gender,
    );
  }

  Future<void> updateCareer({
    required AppUser user,
    required String newCareer,
    required LocalUserProfile? localProfile,
  }) async {
    await _profiles.update(user.uid, 'career', newCareer);
    await _cache(
      user,
      name: localProfile?.name,
      career: newCareer,
      gender: localProfile?.gender,
    );
  }

  Future<void> updateGender({
    required AppUser user,
    required String newGender,
    required LocalUserProfile? localProfile,
  }) async {
    await _profiles.update(user.uid, 'gender', newGender);
    await _cache(
      user,
      name: localProfile?.name,
      career: localProfile?.career,
      gender: newGender,
    );
  }

  Future<void> _cache(
    AppUser user, {
    String? name,
    String? career,
    String? gender,
  }) => UserLocalProfileService().saveProfile(
    uid: user.uid,
    name: name ?? user.displayName ?? '',
    email: user.email ?? '',
    career: career ?? '',
    gender: gender ?? '',
    photoUrl: user.photoURL,
  );

  Future<void> signOut() => AppAuth.instance.signOut();
}
