import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/auth_text_field.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Controladores para Login
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();

  // Controladores para Registro
  final TextEditingController _registerNameController = TextEditingController();
  final TextEditingController _registerEmailController = TextEditingController();
  final TextEditingController _registerCareerController = TextEditingController();
  final TextEditingController _registerPasswordController = TextEditingController();

  FirebaseAuth get _auth => FirebaseAuth.instance;

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

  Future<void> _submitEmailAuth() async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        final email = _loginEmailController.text.trim();
        final password = _loginPasswordController.text.trim();

        if (email.isEmpty || password.isEmpty) {
          _showFeedback('Por favor ingresa correo y contraseÃ±a', isError: true);
          setState(() => _isLoading = false);
          return;
        }

        final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        _showFeedback('Â¡Bienvenido de nuevo, ${userCredential.user?.email}!');
      } else {
        final name = _registerNameController.text.trim();
        final email = _registerEmailController.text.trim();
        final password = _registerPasswordController.text.trim();

        if (email.isEmpty || password.isEmpty) {
          _showFeedback('Por favor completa todos los campos', isError: true);
          setState(() => _isLoading = false);
          return;
        }

        final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (name.isNotEmpty) {
          await userCredential.user?.updateDisplayName(name);
        }

        _showFeedback('Â¡Cuenta creada exitosamente en Firebase!');
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Error en autenticaciÃ³n';
      if (e.code == 'user-not-found') {
        msg = 'No existe una cuenta con este correo';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        msg = 'ContraseÃ±a o correo incorrecto';
      } else if (e.code == 'email-already-in-use') {
        msg = 'Este correo ya estÃ¡ registrado';
      } else if (e.code == 'weak-password') {
        msg = 'La contraseÃ±a debe tener al menos 6 caracteres';
      } else if (e.code == 'invalid-email') {
        msg = 'Formato de correo no vÃ¡lido';
      }
      _showFeedback(msg, isError: true);
    } catch (e) {
      _showFeedback('Error inesperado: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // El usuario cancelÃ³ la selecciÃ³n de cuenta
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      _showFeedback('Â¡Conectado con Google: ${userCredential.user?.displayName}!');
    } catch (e) {
      _showFeedback('Error al acceder con Google: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _enterGuestMode() {
    _showFeedback('Accediendo como Invitado temporal');
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerCareerController.dispose();
    _registerPasswordController.dispose();
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
                  // Logo minimalista
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.medical_services_outlined,
                        size: 34,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Titulo y Subtitulo
                  Text(
                    _isLogin ? 'Iniciar SesiÃ³n' : 'Crear Cuenta',
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
                        ? 'Accede a tus chuletas y quizzes mÃ©dicos'
                        : 'Ãšnete para registrar tu racha y progreso',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Selector de pestanas Login / Registro
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

                  // Boton Principal
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

                  // Boton de Google en Pildora
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

                  // Pildora inferior de Modo Invitado
                  Center(
                    child: TextButton.icon(
                      onPressed: _enterGuestMode,
                      icon: const Icon(Icons.person_outline_rounded, size: 16),
                      label: const Text(
                        'Continuar como Invitado (Probar)',
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
        label: 'Correo ElectrÃ³nico',
        hint: 'ej. estudiante@gmail.com',
        prefixIcon: Icons.alternate_email_rounded,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 14),
      AuthTextField(
        controller: _loginPasswordController,
        label: 'ContraseÃ±a',
        hint: 'â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢',
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
        label: 'Correo ElectrÃ³nico',
        hint: 'ej. estudiante@gmail.com',
        prefixIcon: Icons.mail_outline_rounded,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 14),
      AuthTextField(
        controller: _registerCareerController,
        label: 'Carrera o Especialidad',
        hint: 'ej. Medicina / EnfermerÃ­a',
        prefixIcon: Icons.school_outlined,
      ),
      const SizedBox(height: 14),
      AuthTextField(
        controller: _registerPasswordController,
        label: 'Crear ContraseÃ±a',
        hint: 'MÃ­nimo 6 caracteres',
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
    ];
  }
}