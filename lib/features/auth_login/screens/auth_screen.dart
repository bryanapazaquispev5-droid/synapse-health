import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/user_local_profile_service.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_strength_bar.dart';
import '../widgets/recaptcha_card.dart';
import 'complete_profile_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  bool _isLoading = false;

  // Control de seguridad: Rate Limiting & reCAPTCHA
  int _createdAccountsOnDevice = 0;
  bool _isCaptchaVerified = false;
  int _failedAttemptsCount = 0;
  int _lockoutSeconds = 0;
  Timer? _lockoutTimer;

  @override
  void initState() {
    super.initState();
    _loadSecurityState();
  }

  Future<void> _loadSecurityState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final created = prefs.getInt(AppConstants.prefCreatedAccounts) ?? 0;
      final failed = prefs.getInt(AppConstants.prefFailedLoginAttempts) ?? 0;
      final lockoutUntil = prefs.getInt(AppConstants.prefLoginLockoutUntil) ?? 0;
      final nowInMilliseconds = DateTime.now().millisecondsSinceEpoch;

      if (mounted) {
        setState(() {
          _createdAccountsOnDevice = created;
          _failedAttemptsCount = failed;
        });
      }

      if (lockoutUntil > nowInMilliseconds) {
        _startLockoutTimer((lockoutUntil - nowInMilliseconds) ~/ 1000);
      }
    } catch (_) {}
  }

  void _startLockoutTimer(int durationInSeconds) {
    _lockoutTimer?.cancel();
    setState(() => _lockoutSeconds = durationInSeconds);

    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_lockoutSeconds <= 1) {
        timer.cancel();
        setState(() => _lockoutSeconds = 0);
      } else {
        setState(() => _lockoutSeconds--);
      }
    });
  }

  Future<void> _recordFailedLogin() async {
    _failedAttemptsCount++;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppConstants.prefFailedLoginAttempts, _failedAttemptsCount);

      if (_failedAttemptsCount >= 3) {
        int durationInSeconds = AppConstants.lockoutTier1Seconds; // 3 intentos: 30s
        if (_failedAttemptsCount == 4) {
          durationInSeconds = AppConstants.lockoutTier2Seconds; // 4 intentos: 60s
        } else if (_failedAttemptsCount >= 5) {
          durationInSeconds = AppConstants.lockoutTier3Seconds; // 5+ intentos: 120s
        }

        final lockoutUntil = DateTime.now().millisecondsSinceEpoch + (durationInSeconds * 1000);
        await prefs.setInt(AppConstants.prefLoginLockoutUntil, lockoutUntil);
        _startLockoutTimer(durationInSeconds);

        _showFeedback(
          'Demasiados intentos fallidos ($_failedAttemptsCount). Por seguridad médica, espera $durationInSeconds segundos.',
          isError: true,
        );
      }
    } catch (_) {}
  }

  Future<void> _clearLoginLockout() async {
    _failedAttemptsCount = 0;
    _lockoutSeconds = 0;
    _lockoutTimer?.cancel();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.prefFailedLoginAttempts);
      await prefs.remove(AppConstants.prefLoginLockoutUntil);
    } catch (_) {}
  }

  // Controladores para Login
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();

  // Controladores para Registro
  final TextEditingController _registerNameController = TextEditingController();
  final TextEditingController _registerEmailController = TextEditingController();
  final TextEditingController _registerCareerController = TextEditingController();
  final TextEditingController _registerPasswordController = TextEditingController();
  final TextEditingController _registerConfirmPasswordController = TextEditingController();
  String _registerGender = 'Hombre';

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isError ? AppColors.primary : AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // 1. Recuperar Contraseña por Correo con validación de existencia en Firebase/Firestore
  void _handleOpenForgotPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController(
      text: _loginEmailController.text.trim(),
    );
    String? localError;
    bool isChecking = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Recuperar Contraseña',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Ingresa tu correo registrado y verificaremos tu cuenta antes de enviarte el enlace.',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 18),
                  AuthTextField(
                    controller: resetEmailController,
                    label: 'Correo Electrónico',
                    hint: 'ej. estudiante@gmail.com',
                    prefixIcon: CupertinoIcons.mail,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) {
                      if (localError != null) {
                        setModalState(() => localError = null);
                      }
                    },
                  ),
                  if (localError != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.exclamationmark_circle_fill, color: Color(0xFFDC2626), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              localError!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF991B1B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    child: CupertinoButton.filled(
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(14),
                      onPressed: isChecking
                          ? null
                          : () async {
                              final email = resetEmailController.text.trim().toLowerCase();
                              if (email.isEmpty) {
                                setModalState(() => localError = 'Ingresa un correo electrónico.');
                                return;
                              }
                              final bool validEmail = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
                              if (!validEmail) {
                                setModalState(() => localError = 'Formato de correo no válido.');
                                return;
                              }

                              setModalState(() {
                                isChecking = true;
                                localError = null;
                              });

                              try {
                                final snapshot = await _firestore
                                    .collection(AppConstants.firestoreUsers)
                                    .where('email', isEqualTo: email)
                                    .limit(1)
                                    .get();

                                if (snapshot.docs.isEmpty) {
                                  setModalState(() {
                                    isChecking = false;
                                    localError = 'Este correo no está registrado en el sistema.';
                                  });
                                  return;
                                }

                                // Si existe, enviar el correo de recuperación
                                await _auth.sendPasswordResetEmail(email: email);
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  _showFeedback('¡Enlace enviado a $email! Revisa tu bandeja o spam.');
                                }
                              } on FirebaseAuthException catch (e) {
                                setModalState(() {
                                  isChecking = false;
                                  if (e.code == 'user-not-found') {
                                    localError = 'Este correo no está registrado en Firebase.';
                                  } else {
                                    localError = 'Error: ${e.message}';
                                  }
                                });
                              } catch (e) {
                                setModalState(() {
                                  isChecking = false;
                                  localError = 'Ocurrió un error al verificar: $e';
                                });
                              }
                            },
                      child: isChecking
                          ? const CupertinoActivityIndicator(color: AppColors.surface)
                          : const Text(
                              'Enviar Enlace de Recuperación',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.surface),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 2, 4 y 5. Registro con Anti-Bot Captcha y Login con Rate Limiting
  Future<void> _handleSubmitEmailAuth() async {
    FocusScope.of(context).unfocus();

    // Validar si el inicio de sesión está bloqueado por intentos fallidos
    if (_isLogin && _lockoutSeconds > 0) {
      _showFeedback(
        'Acceso temporalmente bloqueado. Espera $_lockoutSeconds s antes de reintentar.',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        final email = _loginEmailController.text.trim().toLowerCase();
        final password = _loginPasswordController.text.trim();

        if (email.isEmpty || password.isEmpty) {
          _showFeedback('Por favor ingresa correo y contraseña', isError: true);
          setState(() => _isLoading = false);
          return;
        }

        final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Login exitoso: limpiar bloqueos e intentos fallidos
        await _clearLoginLockout();

        // Cargar y almacenar perfil localmente para soporte offline
        if (userCredential.user != null) {
          try {
            final docSnapshot = await _firestore
                .collection(AppConstants.firestoreUsers)
                .doc(userCredential.user!.uid)
                .get();
            final d = docSnapshot.data();
            if (d != null) {
              await UserLocalProfileService().saveProfile(
                uid: userCredential.user!.uid,
                name: d['name'] ?? userCredential.user!.displayName ?? '',
                email: d['email'] ?? userCredential.user!.email ?? '',
                career: d['career'] ?? 'Medicina Humana',
                gender: d['gender'] ?? 'Hombre',
                photoUrl: userCredential.user!.photoURL,
              );
            }
          } catch (_) {}
        }

        _showFeedback('¡Bienvenido de nuevo, ${userCredential.user?.email}!');
      } else {
        // En Registro: Si ya se creó al menos 1 cuenta en este celular, requerir reCAPTCHA
        if (_createdAccountsOnDevice >= 1 && !_isCaptchaVerified) {
          _showFeedback(
            'Por seguridad anti-bots, marca la casilla "No soy un robot" para continuar.',
            isError: true,
          );
          setState(() => _isLoading = false);
          return;
        }

        final name = _registerNameController.text.trim();
        final email = _registerEmailController.text.trim().toLowerCase();
        final career = _registerCareerController.text.trim();
        final password = _registerPasswordController.text.trim();
        final confirmPassword = _registerConfirmPasswordController.text.trim();

        if (name.isEmpty || email.isEmpty || career.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
          _showFeedback('Por favor completa todos los campos', isError: true);
          setState(() => _isLoading = false);
          return;
        }

        final bool validEmail = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
        if (!validEmail) {
          _showFeedback('Por favor ingresa un correo electrónico válido', isError: true);
          setState(() => _isLoading = false);
          return;
        }

        // Validación de coincidencia de contraseñas
        if (password != confirmPassword) {
          _showFeedback('Las contraseñas no coinciden', isError: true);
          setState(() => _isLoading = false);
          return;
        }

        if (password.length < 6) {
          _showFeedback('La contraseña debe tener mínimo 6 caracteres', isError: true);
          setState(() => _isLoading = false);
          return;
        }

        // Validación de seguridad: La contraseña no puede ser igual al correo
        final String emailLower = email.toLowerCase().trim();
        final String passwordLower = password.toLowerCase().trim();
        final String emailPrefix = emailLower.contains('@') ? emailLower.split('@')[0] : '';

        if (passwordLower == emailLower || (emailPrefix.length >= 3 && passwordLower == emailPrefix)) {
          _showFeedback('Por seguridad, la contraseña no puede ser igual a tu correo.', isError: true);
          setState(() => _isLoading = false);
          return;
        }

        // Crear usuario en Firebase Auth
        final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = userCredential.user;
        if (user != null) {
          await user.updateDisplayName(name);
          await user.sendEmailVerification();

          await _firestore.collection(AppConstants.firestoreUsers).doc(user.uid).set({
            'uid': user.uid,
            'name': name,
            'email': email,
            'career': career,
            'gender': _registerGender,
            'studyStreakDays': 0,
            'createdAt': FieldValue.serverTimestamp(),
            'authProvider': 'password',
          }, SetOptions(merge: true));

          // Guardar perfil del usuario localmente para soporte offline
          await UserLocalProfileService().saveProfile(
            uid: user.uid,
            name: name,
            email: email,
            career: career,
            gender: _registerGender,
            photoUrl: user.photoURL,
          );

          // Limpiar documentos huérfanos de cuentas previamente eliminadas
          try {
            final oldDocs = await _firestore
                .collection(AppConstants.firestoreUsers)
                .where('email', isEqualTo: email)
                .get();
            for (final d in oldDocs.docs) {
              if (d.id != user.uid) {
                await d.reference.delete();
              }
            }
          } catch (_) {}

          // Registrar que se creó una cuenta en este celular
          try {
            final prefs = await SharedPreferences.getInstance();
            final current = prefs.getInt(AppConstants.prefCreatedAccounts) ?? 0;
            await prefs.setInt(AppConstants.prefCreatedAccounts, current + 1);
            if (mounted) {
              setState(() => _createdAccountsOnDevice = current + 1);
            }
          } catch (_) {}
        }

        _showFeedback('¡Cuenta médica creada! Te enviamos un correo de verificación.');
      }
    } on FirebaseAuthException catch (e) {
      if (_isLogin) {
        // Registrar intento fallido para activar bloqueo progresivo
        await _recordFailedLogin();
      }

      String msg = 'Error en autenticación';
      if (e.code == 'user-not-found') {
        msg = 'No existe ninguna cuenta registrada con este correo';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        msg = 'Contraseña o correo incorrecto';
      } else if (e.code == 'email-already-in-use') {
        msg = 'Este correo ya está registrado en el sistema. Inicia sesión o recupera tu clave.';
      } else if (e.code == 'account-exists-with-different-credential') {
        msg = 'Este correo ya está registrado con Google. Inicia sesión usando Google.';
      } else if (e.code == 'weak-password') {
        msg = 'La contraseña debe tener al menos 6 caracteres';
      } else if (e.code == 'invalid-email') {
        msg = 'Formato de correo no válido';
      } else if (e.code == 'too-many-requests') {
        msg = 'Demasiados intentos. Tu acceso ha sido pausado temporalmente.';
      }
      _showFeedback(msg, isError: true);
    } catch (e) {
      _showFeedback('Error inesperado: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Google Sign-In con sincronización a Firestore
  Future<void> _handleSignInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      // Limpiar bloqueos de login
      await _clearLoginLockout();

      if (user != null) {
        try {
          final docSnapshot = await _firestore
              .collection(AppConstants.firestoreUsers)
              .doc(user.uid)
              .get();

          final data = docSnapshot.data();
          final String? career = data?['career'];

          if (career == null || career.trim().isEmpty) {
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CompleteProfileScreen(user: user),
                ),
              );
              return;
            }
          } else {
            // Guardar perfil existente de Google en caché local para visualización offline
            await UserLocalProfileService().saveProfile(
              uid: user.uid,
              name: data?['name'] ?? user.displayName ?? '',
              email: data?['email'] ?? user.email ?? '',
              career: career,
              gender: data?['gender'] ?? 'Hombre',
              photoUrl: user.photoURL,
            );
          }
        } catch (_) {}
      }

      _showFeedback('¡Conectado con Google: ${userCredential.user?.displayName}!');
    } catch (e) {
      _showFeedback('Error al acceder con Google: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 3. Modo Invitado Real (Firebase Anonymous Auth)
  Future<void> _handleSignInAsGuest() async {
    setState(() => _isLoading = true);
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();
      final user = userCredential.user;

      if (user != null) {
        await _firestore.collection(AppConstants.firestoreUsers).doc(user.uid).set({
          'uid': user.uid,
          'name': 'Invitado Temporal',
          'email': 'invitado@synapse.app',
          'career': 'Visitante de Salud',
          'studyStreakDays': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'authProvider': 'anonymous',
        }, SetOptions(merge: true));
      }

      _showFeedback('¡Acceso concedido como Invitado temporal!');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'admin-restricted-operation' || e.code == 'operation-not-allowed') {
        _showFeedback(
          'Para usar Invitado, activa el proveedor "Anónimo" en tu consola de Firebase.',
          isError: true,
        );
      } else {
        _showFeedback('Error en modo invitado: ${e.message}', isError: true);
      }
    } catch (e) {
      _showFeedback('Error en modo invitado: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerCareerController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLockoutActive = _isLogin && _lockoutSeconds > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo oficial de la aplicación
                  Center(
                    child: Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/app_logo.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Título y Subtítulo
                  Text(
                    _isLogin ? 'Iniciar Sesión' : 'Crear Cuenta',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isLogin
                        ? 'Accede a tus chuletas y quizzes médicos'
                        : 'Únete para registrar tu racha y progreso',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Selector de pestañas iOS (CupertinoSlidingSegmentedControl)
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoSlidingSegmentedControl<bool>(
                      groupValue: _isLogin,
                      backgroundColor: const Color(0xFFE5E5EA),
                      thumbColor: AppColors.surface,
                      padding: const EdgeInsets.all(3),
                      children: const {
                        true: Padding(
                          padding: EdgeInsets.symmetric(vertical: 9),
                          child: Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        false: Padding(
                          padding: EdgeInsets.symmetric(vertical: 9),
                          child: Text(
                            'Registrarse',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      },
                      onValueChanged: (val) {
                        if (val != null) setState(() => _isLogin = val);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Banner de Bloqueo por Intentos Fallidos
                  if (isLockoutActive) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.timer, color: Color(0xFFDC2626), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Demasiados intentos fallidos ($_failedAttemptsCount). Espera $_lockoutSeconds segundos...',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF991B1B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Formulario condicional
                  if (_isLogin) ..._buildLoginForm() else ..._buildRegisterForm(),

                  const SizedBox(height: 24),

                  // Botón Principal iOS (Vibrant Apple Blue)
                  SizedBox(
                    height: 50,
                    child: CupertinoButton.filled(
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(14),
                      onPressed: (_isLoading || isLockoutActive) ? null : _handleSubmitEmailAuth,
                      child: _isLoading
                          ? const CupertinoActivityIndicator(color: AppColors.surface)
                          : isLockoutActive
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(CupertinoIcons.lock_fill, size: 18, color: AppColors.surface),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Bloqueado ($_lockoutSeconds s)',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.surface,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _isLogin ? 'Iniciar Sesión' : 'Crear Cuenta Médica',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.surface,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(CupertinoIcons.arrow_right, size: 16, color: AppColors.surface),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Botón de Google
                  SizedBox(
                    height: 50,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      onPressed: _isLoading ? null : _handleSignInWithGoogle,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border, width: 1.2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.g_mobiledata_rounded, size: 28, color: AppColors.accent),
                            SizedBox(width: 6),
                            Text(
                              'Continuar con Google',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Modo Invitado
                  Center(
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      onPressed: _isLoading ? null : _handleSignInAsGuest,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(CupertinoIcons.person_crop_circle, size: 16, color: AppColors.textMuted),
                          SizedBox(width: 6),
                          Text(
                            'Continuar como Invitado (Modo Prueba)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLoginForm() {
    return [
      AuthTextField(
        controller: _loginEmailController,
        label: 'Correo Electrónico',
        hint: 'ej. estudiante@gmail.com',
        prefixIcon: CupertinoIcons.mail,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 14),
      AuthTextField(
        controller: _loginPasswordController,
        label: 'Contraseña',
        hint: '••••••••',
        prefixIcon: CupertinoIcons.lock,
        obscureText: _isPasswordObscured,
        suffixIcon: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            _isPasswordObscured ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
        ),
      ),
      // Enlace de Recuperar Contraseña
      Align(
        alignment: Alignment.centerRight,
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          onPressed: _handleOpenForgotPasswordDialog,
          child: const Text(
            '¿Olvidaste tu contraseña?',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildRegisterForm() {
    final bool requireCaptcha = _createdAccountsOnDevice >= 1;

    return [
      AuthTextField(
        controller: _registerNameController,
        label: 'Nombre Completo',
        hint: 'ej. Bryan Apaza',
        prefixIcon: CupertinoIcons.person,
      ),
      const SizedBox(height: 14),
      AuthTextField(
        controller: _registerEmailController,
        label: 'Correo Electrónico',
        hint: 'ej. estudiante@gmail.com',
        prefixIcon: CupertinoIcons.mail,
        keyboardType: TextInputType.emailAddress,
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 14),
      AuthTextField(
        controller: _registerCareerController,
        label: 'Carrera o Especialidad',
        hint: 'ej. Medicina Humana / Enfermería',
        prefixIcon: CupertinoIcons.book,
      ),
      const SizedBox(height: 14),
      // Selector de Género (Hombre / Mujer) con CupertinoSlidingSegmentedControl
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 2, bottom: 8),
              child: Text(
                'Género del Estudiante',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<String>(
                groupValue: _registerGender,
                backgroundColor: const Color(0xFFF1F5F9),
                thumbColor: AppColors.surface,
                padding: const EdgeInsets.all(4),
                children: const {
                  'Hombre': Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.person_fill, size: 16, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text('Hombre', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ],
                    ),
                  ),
                  'Mujer': Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.person_alt, size: 16, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text('Mujer', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ],
                    ),
                  ),
                },
                onValueChanged: (val) {
                  if (val != null) setState(() => _registerGender = val);
                },
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      AuthTextField(
        controller: _registerPasswordController,
        label: 'Crear Contraseña',
        hint: 'Mínimo 6 caracteres',
        prefixIcon: CupertinoIcons.lock,
        obscureText: _isPasswordObscured,
        onChanged: (_) => setState(() {}),
        suffixIcon: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            _isPasswordObscured ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
        ),
      ),
      PasswordStrengthBar(
        password: _registerPasswordController.text,
        email: _registerEmailController.text,
      ),
      const SizedBox(height: 14),
      AuthTextField(
        controller: _registerConfirmPasswordController,
        label: 'Confirmar Contraseña',
        hint: 'Repite tu contraseña',
        prefixIcon: CupertinoIcons.lock_shield,
        obscureText: _isConfirmPasswordObscured,
        suffixIcon: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            _isConfirmPasswordObscured ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: () => setState(() => _isConfirmPasswordObscured = !_isConfirmPasswordObscured),
        ),
      ),

      // Casilla Google reCAPTCHA: solo si ya se creó 1 cuenta previa en este celular
      if (requireCaptcha) ...[
        RecaptchaCard(
          isVerified: _isCaptchaVerified,
          onVerified: (verified) => setState(() => _isCaptchaVerified = verified),
        ),
      ],
    ];
  }
}