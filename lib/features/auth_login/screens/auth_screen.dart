import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_strength_bar.dart';
import '../widgets/recaptcha_card.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // Control de seguridad: Rate Limiting & reCAPTCHA
  int _createdAccountsOnDevice = 0;
  bool _captchaVerified = false;
  int _failedAttempts = 0;
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
      final created = prefs.getInt('created_accounts_on_device') ?? 0;
      final failed = prefs.getInt('failed_login_attempts') ?? 0;
      final lockoutUntil = prefs.getInt('login_lockout_until') ?? 0;
      final nowMs = DateTime.now().millisecondsSinceEpoch;

      if (mounted) {
        setState(() {
          _createdAccountsOnDevice = created;
          _failedAttempts = failed;
        });
      }

      if (lockoutUntil > nowMs) {
        _startLockoutTimer((lockoutUntil - nowMs) ~/ 1000);
      }
    } catch (_) {}
  }

  void _startLockoutTimer(int seconds) {
    _lockoutTimer?.cancel();
    setState(() => _lockoutSeconds = seconds);

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
    _failedAttempts++;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('failed_login_attempts', _failedAttempts);

      if (_failedAttempts >= 3) {
        int duration = 30; // 3 intentos: 30s
        if (_failedAttempts == 4) {
          duration = 60; // 4 intentos: 60s
        } else if (_failedAttempts >= 5) {
          duration = 120; // 5+ intentos: 120s
        }

        final lockoutUntil = DateTime.now().millisecondsSinceEpoch + (duration * 1000);
        await prefs.setInt('login_lockout_until', lockoutUntil);
        _startLockoutTimer(duration);

        _showFeedback(
          'Demasiados intentos fallidos ($_failedAttempts). Por seguridad médica, espera $duration segundos.',
          isError: true,
        );
      }
    } catch (_) {}
  }

  Future<void> _clearLoginLockout() async {
    _failedAttempts = 0;
    _lockoutSeconds = 0;
    _lockoutTimer?.cancel();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('failed_login_attempts');
      await prefs.remove('login_lockout_until');
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // 1. Recuperar Contraseña por Correo con validación de existencia en Firebase/Firestore
  void _openForgotPasswordDialog() {
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
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
                    prefixIcon: Icons.alternate_email_rounded,
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
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
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
                    height: 48,
                    child: ElevatedButton(
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
                                    .collection('users')
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surface,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: isChecking
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.surface),
                            )
                          : const Text(
                              'Enviar Enlace de Recuperación',
                              style: TextStyle(fontWeight: FontWeight.w700),
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
  Future<void> _submitEmailAuth() async {
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

        _showFeedback('¡Bienvenido de nuevo, ${userCredential.user?.email}!');
      } else {
        // En Registro: Si ya se creó al menos 1 cuenta en este celular, requerir reCAPTCHA
        if (_createdAccountsOnDevice >= 1 && !_captchaVerified) {
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

        // Crear usuario en Firebase Auth directamente (fuente de verdad)

        // Crear usuario en Firebase Auth
        final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = userCredential.user;
        if (user != null) {
          await user.updateDisplayName(name);
          await user.sendEmailVerification();

          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': name,
            'email': email,
            'career': career,
            'gender': _registerGender,
            'studyStreakDays': 0,
            'createdAt': FieldValue.serverTimestamp(),
            'authProvider': 'password',
          }, SetOptions(merge: true));

          // Limpiar documentos huérfanos de cuentas previamente eliminadas
          try {
            final oldDocs = await _firestore
                .collection('users')
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
            final current = prefs.getInt('created_accounts_on_device') ?? 0;
            await prefs.setInt('created_accounts_on_device', current + 1);
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
  Future<void> _signInWithGoogle() async {
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

      // Limpiar bloqueos de login
      await _clearLoginLockout();

      // No creamos documento en Firestore todavía: solo se creará si el usuario completa su carrera en CompleteProfileScreen

      _showFeedback('¡Conectado con Google: ${userCredential.user?.displayName}!');
    } catch (e) {
      _showFeedback('Error al acceder con Google: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 3. Modo Invitado Real (Firebase Anonymous Auth)
  Future<void> _signInAsGuest() async {
    setState(() => _isLoading = true);
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();
      final user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
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

                  // Selector de pestañas Login / Registro
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _tabButton(
                            title: 'Ingresar',
                            isSelected: _isLogin,
                            onTap: () => setState(() => _isLogin = true),
                          ),
                        ),
                        Expanded(
                          child: _tabButton(
                            title: 'Registrarse',
                            isSelected: !_isLogin,
                            onTap: () => setState(() => _isLogin = false),
                          ),
                        ),
                      ],
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
                          const Icon(Icons.timer_outlined, color: Color(0xFFDC2626), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Demasiados intentos fallidos ($_failedAttempts). Por seguridad médica, espera $_lockoutSeconds segundos...',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
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

                  // Botón Principal
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (_isLoading || isLockoutActive) ? null : _submitEmailAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLockoutActive ? const Color(0xFF94A3B8) : AppColors.primary,
                        foregroundColor: AppColors.surface,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: AppColors.surface,
                              ),
                            )
                          : isLockoutActive
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.lock_clock_rounded, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Bloqueado ($_lockoutSeconds s)',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _isLogin ? 'Acceder al Sistema' : 'Completar Registro',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward_rounded, size: 18),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botón de Google
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _signInWithGoogle,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.border, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
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
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Modo Invitado
                  Center(
                    child: TextButton.icon(
                      onPressed: _isLoading ? null : _signInAsGuest,
                      icon: const Icon(Icons.person_outline_rounded, size: 16),
                      label: const Text(
                        'Continuar como Invitado (Modo Prueba)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textMuted,
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

  Widget _tabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.surface : AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _genderOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.surface : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.surface : AppColors.primary,
              ),
            ),
          ],
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
        prefixIcon: Icons.alternate_email_rounded,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 14),
      AuthTextField(
        controller: _loginPasswordController,
        label: 'Contraseña',
        hint: '••••••••',
        prefixIcon: Icons.lock_outline_rounded,
        obscureText: _obscurePassword,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      // Enlace de Recuperar Contraseña
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: _openForgotPasswordDialog,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          ),
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
        prefixIcon: Icons.badge_outlined,
      ),
      const SizedBox(height: 14),
      AuthTextField(
        controller: _registerEmailController,
        label: 'Correo Electrónico',
        hint: 'ej. estudiante@gmail.com',
        prefixIcon: Icons.mail_outline_rounded,
        keyboardType: TextInputType.emailAddress,
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 14),
      AuthTextField(
        controller: _registerCareerController,
        label: 'Carrera o Especialidad',
        hint: 'ej. Medicina Humana / Enfermería',
        prefixIcon: Icons.school_outlined,
      ),
      const SizedBox(height: 14),
      // Selector de Género (Hombre / Mujer)
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Género del Estudiante',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _genderOption(
                    label: 'Hombre',
                    icon: Icons.male_rounded,
                    isSelected: _registerGender == 'Hombre',
                    onTap: () => setState(() => _registerGender = 'Hombre'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _genderOption(
                    label: 'Mujer',
                    icon: Icons.female_rounded,
                    isSelected: _registerGender == 'Mujer',
                    onTap: () => setState(() => _registerGender = 'Mujer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      AuthTextField(
        controller: _registerPasswordController,
        label: 'Crear Contraseña',
        hint: 'Mínimo 6 caracteres',
        prefixIcon: Icons.lock_outline_rounded,
        obscureText: _obscurePassword,
        onChanged: (_) => setState(() {}),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
        prefixIcon: Icons.lock_clock_outlined,
        obscureText: _obscureConfirmPassword,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
        ),
      ),

      // Casilla Google reCAPTCHA: solo si ya se creó 1 cuenta previa en este celular
      if (requireCaptcha) ...[
        RecaptchaCard(
          isVerified: _captchaVerified,
          onVerified: (verified) => setState(() => _captchaVerified = verified),
        ),
      ],
    ];
  }
}