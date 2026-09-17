// ============================================================================
// Archivo: profile_api_service.dart
// Propósito: Servicio de integración con Firestore para actualizar datos del perfil, limpiar tokens y cerrar sesión.
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/notifications/services/push_notification_service.dart';
import '../../../core/services/user_local_profile_service.dart';

/// Servicio de arquitectura y lógica de negocio para [ProfileApiService].
class ProfileApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserProfileStream(String uid) {
    return _firestore.collection(AppConstants.FIRESTORE_USERS).doc(uid).snapshots();
  }

  Future<void> updateName({
    required User user,
    required String newName,
    required LocalUserProfile? localProfile,
  }) async {
    await user.updateDisplayName(newName);
    await UserLocalProfileService().saveProfile(
      uid: user.uid,
      name: newName,
      email: user.email ?? '',
      career: localProfile?.career ?? 'Medicina Humana',
      gender: localProfile?.gender ?? 'Hombre',
      photoUrl: user.photoURL,
    );
    await _firestore
        .collection(AppConstants.FIRESTORE_USERS)
        .doc(user.uid)
        .set({'name': newName}, SetOptions(merge: true));
  }

  Future<void> updateCareer({
    required User user,
    required String newCareer,
    required LocalUserProfile? localProfile,
  }) async {
    await UserLocalProfileService().saveProfile(
      uid: user.uid,
      name: localProfile?.name ?? user.displayName ?? '',
      email: user.email ?? '',
      career: newCareer.trim(),
      gender: localProfile?.gender ?? 'Hombre',
      photoUrl: user.photoURL,
    );
    await _firestore
        .collection(AppConstants.FIRESTORE_USERS)
        .doc(user.uid)
        .set({'career': newCareer.trim()}, SetOptions(merge: true));
  }

  Future<void> updateGender({
    required User user,
    required String newGender,
    required LocalUserProfile? localProfile,
  }) async {
    await UserLocalProfileService().saveProfile(
      uid: user.uid,
      name: localProfile?.name ?? user.displayName ?? '',
      email: user.email ?? '',
      career: localProfile?.career ?? 'Medicina Humana',
      gender: newGender,
      photoUrl: user.photoURL,
    );
    await _firestore
        .collection(AppConstants.FIRESTORE_USERS)
        .doc(user.uid)
        .set({'gender': newGender}, SetOptions(merge: true));
  }

  Future<void> signOut() async {
    // Bloque: Ejecución protegida de operación asíncrona
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await PushNotificationService().handleLogout(uid);
      }
    } catch (_) {}
    // Bloque: Ejecución protegida de operación asíncrona
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (_) {}
    await FirebaseAuth.instance.signOut();
  }
}
