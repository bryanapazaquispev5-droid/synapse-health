import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/google_accounts_service.dart';
import '../../../core/services/user_local_profile_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;

  /// Inicia sesión con correo y contraseña
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password.trim(),
    );

    final user = userCredential.user;
    if (user != null) {
      try {
        final doc = await _firestore.collection(AppConstants.FIRESTORE_USERS).doc(user.uid).get();
        final data = doc.data();
        if (data != null) {
          await UserLocalProfileService().saveProfile(
            uid: user.uid,
            name: data['name'] ?? user.displayName ?? '',
            email: data['email'] ?? user.email ?? '',
            career: data['career'] ?? 'Medicina Humana',
            gender: data['gender'] ?? 'Hombre',
            photoUrl: user.photoURL,
          );
        }
      } catch (_) {}
    }

    return userCredential;
  }

  /// Registra una nueva cuenta médica
  Future<UserCredential> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String career,
    required String gender,
    required String password,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password.trim(),
    );

    final user = userCredential.user;
    if (user != null) {
      await user.updateDisplayName(name.trim());
      await user.sendEmailVerification();

      await _firestore.collection(AppConstants.FIRESTORE_USERS).doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'career': career.trim(),
        'gender': gender,
        'studyStreakDays': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'authProvider': 'password',
      }, SetOptions(merge: true));

      await UserLocalProfileService().saveProfile(
        uid: user.uid,
        name: name.trim(),
        email: email.trim().toLowerCase(),
        career: career.trim(),
        gender: gender,
        photoUrl: user.photoURL,
      );

      try {
        final oldDocs = await _firestore
            .collection(AppConstants.FIRESTORE_USERS)
            .where('email', isEqualTo: email.trim().toLowerCase())
            .get();
        for (final d in oldDocs.docs) {
          if (d.id != user.uid) {
            await d.reference.delete();
          }
        }
      } catch (_) {}
    }

    return userCredential;
  }

  /// Verifica si el correo está registrado en Firestore antes de enviar reset
  Future<bool> isEmailRegisteredInFirestore(String email) async {
    final snapshot = await _firestore
        .collection(AppConstants.FIRESTORE_USERS)
        .where('email', isEqualTo: email.trim().toLowerCase())
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  /// Envía correo para recuperar contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
  }

  /// Flujo OAuth2 Google Sign-In (Token directo via AccountManager / Fallback / Nativo)
  Future<UserCredential?> signInWithGoogle({String? hintEmail}) async {
    UserCredential? userCredential;

    if (hintEmail != null) {
      bool authenticated = false;
      try {
        final String? token = await GoogleAccountsService.getGoogleAuthToken(hintEmail);
        if (token != null && token.isNotEmpty) {
          final credential = GoogleAuthProvider.credential(accessToken: token);
          userCredential = await _auth.signInWithCredential(credential);
          authenticated = true;
        }
      } catch (_) {}

      if (!authenticated) {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        GoogleSignInAccount? googleUser = await googleSignIn.signInSilently();

        if (googleUser == null || googleUser.email != hintEmail) {
          await googleSignIn.signOut();
          googleUser = await googleSignIn.signIn();
        }

        if (googleUser == null) return null;

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await _auth.signInWithCredential(credential);
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      userCredential = await _auth.signInWithCredential(credential);
    }

    if (userCredential == null) return null;

    final user = userCredential.user;
    if (user != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        if (user.email != null) await prefs.setString('last_google_email', user.email!);
        if (user.displayName != null) await prefs.setString('last_google_name', user.displayName!);
        if (user.photoURL != null) await prefs.setString('last_google_photo', user.photoURL!);
      } catch (_) {}
    }

    return userCredential;
  }

  /// Inicia sesión como Invitado temporal (Anonymous)
  Future<UserCredential> signInAnonymously() async {
    final userCredential = await _auth.signInAnonymously();
    final user = userCredential.user;

    if (user != null) {
      await _firestore.collection(AppConstants.FIRESTORE_USERS).doc(user.uid).set({
        'uid': user.uid,
        'name': 'Invitado Temporal',
        'email': 'invitado@synapse.app',
        'career': 'Visitante de Salud',
        'studyStreakDays': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'authProvider': 'anonymous',
      }, SetOptions(merge: true));
    }

    return userCredential;
  }

  /// Cancela el registro y elimina la cuenta temporal
  Future<void> cancelAndRollbackAccount(User user) async {
    try {
      await user.delete();
    } catch (_) {}
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    try {
      await _auth.signOut();
    } catch (_) {}
  }
}
