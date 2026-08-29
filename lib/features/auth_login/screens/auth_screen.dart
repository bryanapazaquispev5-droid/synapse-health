import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_strength_bar.dart';

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

  // Controladores para Login
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();

  // Controladores para Registro
  final TextEditingController _registerNameController = TextEditingController();
  final TextEditingController _registerEmailController = TextEditingController();
  final TextEditingController _registerCareerController = TextEditingController();
  final TextEditingController _registerPasswordController = TextEditingController();
  final TextEditingController _registerConfirmPasswordController = TextEditingController();

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

  // 2, 4 y 5. Registro con Validación de Duplicados, Confirmación y Firestore
  Future<void> _submitEmailAuth() async {
    FocusScope.of(context).unfocus();
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

        _showFeedback('¡Bienvenido de nuevo, ${userCredential.user?.email}!');
      } else {
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

        final existingCheck = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (existingCheck.docs.isNotEmpty) {
          final provider = existingCheck.docs.first.data()['authProvider'] ?? '';
          if (provider == 'google.com') {
            _showFeedback(
              'Este correo ya está registrado con Google. Por favor ingresa con el botón "Continuar con Google".',
              isError: true,
            );
          } else {
            _showFeedback(
              'Este correo ya está registrado en el sistema. Inicia sesión o recupera tu contraseña.',
              isError: true,
            );
          }
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

          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': name,
            'email': email,
            'career': career,
            'studyStreakDays': 0,
            'createdAt': FieldValue.serverTimestamp(),
            'authProvider': 'password',
          }, SetOptions(merge: true));
        }

        _showFeedback('¡Cuenta médica creada! Te enviamos un correo de verificación.');
      }
    } on FirebaseAuthException catch (e) {
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
      final user = userCredential.user;

      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          // Usuario nuevo con Google: se crea el documento y luego CompleteProfileScreen pedirá su carrera
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': user.displayName ?? '',
            'email': user.email?.toLowerCase() ?? '',
            'career': null,
            'studyStreakDays': 0,
            'createdAt': FieldValue.serverTimestamp(),
            'authProvider': 'google.com',
          });
        }
      }

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

                  // Formulario condicional
                  if (_isLogin) ..._buildLoginForm() else ..._buildRegisterForm(),

                  const SizedBox(height: 24),

                  // Botón Principal
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitEmailAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
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
      ),
      const SizedBox(height: 14),
      AuthTextField(
        controller: _registerCareerController,
        label: 'Carrera o Especialidad',
        hint: 'ej. Medicina Humana / Enfermería',
        prefixIcon: Icons.school_outlined,
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
      PasswordStrengthBar(password: _registerPasswordController.text),
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
    ];
  }
}