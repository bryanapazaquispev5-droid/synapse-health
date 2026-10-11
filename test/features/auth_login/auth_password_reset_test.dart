import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/features/auth_login/api/auth_service.dart';

class ResetAuth extends Fake implements FirebaseAuth {
  String? requestedEmail;
  String? errorCode;

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
    ActionCodeSettings? actionCodeSettings,
  }) async {
    requestedEmail = email;
    if (errorCode != null) throw FirebaseAuthException(code: errorCode!);
  }
}

// Any Firestore access fails: password recovery must use Auth exclusively.
class UnusedFirestore extends Fake implements FirebaseFirestore {}

void main() {
  late ResetAuth auth;
  late AuthService service;

  setUp(() {
    auth = ResetAuth();
    service = AuthService(auth: auth, firestore: UnusedFirestore());
  });

  test('normalizes email and requests reset without reading profiles', () async {
    await service.sendPasswordResetEmail('  Student@Example.test  ');
    expect(auth.requestedEmail, 'student@example.test');
  });

  test('unknown email receives the same completion as a known account', () async {
    auth.errorCode = 'user-not-found';
    await expectLater(service.sendPasswordResetEmail('absent@example.test'), completes);
    expect(auth.requestedEmail, 'absent@example.test');
  });

  test('network and rate-limit failures are not hidden', () async {
    for (final code in ['network-request-failed', 'too-many-requests']) {
      auth.errorCode = code;
      await expectLater(
        service.sendPasswordResetEmail('student@example.test'),
        throwsA(isA<FirebaseAuthException>().having((e) => e.code, 'code', code)),
      );
    }
  });
}
