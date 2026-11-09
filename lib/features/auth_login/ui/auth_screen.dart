// ============================================================================
// File: auth_screen.dart
// Purpose: Main user interface screen for the authentication flow [auth_screen].
// ============================================================================

import 'package:flutter/material.dart';

import '../model/trial_mode_session.dart';

import '../../../core/theme/app_theme.dart';
import '../api/auth_lockout_manager.dart';
import '../api/remembered_email_store.dart';
import '../api/auth_service.dart';
import '../model/auth_flow_handler.dart';
import '../utils/auth_snackbar_helper.dart';
import 'widgets/auth_action_buttons.dart';
import 'widgets/auth_forgot_password_sheet.dart';
import 'widgets/auth_header_widget.dart';
import 'widgets/auth_lockout_banner.dart';
import 'widgets/auth_login_form.dart';
import 'widgets/auth_mode_selector.dart';
import 'widgets/auth_register_form.dart';

// User interface screen [AuthScreen]
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

// Reactive state and lifecycle management for [AuthScreen]
class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final AuthLockoutManager _lockoutManager = AuthLockoutManager();
  final RememberedEmailStore _rememberedEmailStore = RememberedEmailStore();

  bool _isLogin = true;
  bool _isLoading = false;
  int _createdAccountsOnDevice = 0;
  bool _isCaptchaVerified = false;
  bool _rememberEmail = false;
  bool _rememberEmailWasChanged = false;

  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();

  final TextEditingController _registerNameController = TextEditingController();
  final TextEditingController _registerEmailController =
      TextEditingController();
  final TextEditingController _registerCareerController =
      TextEditingController();
  final TextEditingController _registerPasswordController =
      TextEditingController();
  final TextEditingController _registerConfirmPasswordController =
      TextEditingController();
  String _registerGender = 'Hombre';

  late final AuthFlowHandler _flowHandler = AuthFlowHandler(
    authService: _authService,
    lockoutManager: _lockoutManager,
  );

  // Initialize component dependencies and local state
  @override
  void initState() {
    super.initState();
    _restoreRememberedEmail();
    _lockoutManager.loadSecurityState(
      onStateLoaded: (created, failed) {
        if (mounted) setState(() => _createdAccountsOnDevice = created);
      },
      onLockoutUpdate: (sec) {
        if (mounted) setState(() {});
      },
    );
  }

  Future<void> _restoreRememberedEmail() async {
    try {
      final email = await _rememberedEmailStore.load();
      if (email == null || !mounted || _rememberEmailWasChanged) return;
      _loginEmailController.text = email;
      setState(() => _rememberEmail = true);
    } catch (_) {}
  }

  Future<void> _saveRememberedEmail(String? email) async {
    try {
      await _rememberedEmailStore.save(email);
    } catch (_) {}
  }

  Future<void> _setRememberEmail(bool enabled) async {
    _rememberEmailWasChanged = true;
    setState(() => _rememberEmail = enabled);
    await _saveRememberedEmail(enabled ? _loginEmailController.text : null);
  }

  void _handleLoginEmailChanged(String email) {
    _rememberEmailWasChanged = true;
    if (_rememberEmail) _saveRememberedEmail(email);
  }

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    AuthSnackbarHelper.show(context, message, isError: isError);
  }

  void _handleOpenForgotPasswordDialog() {
    AuthForgotPasswordSheet.show(
      context: context,
      initialEmail: _loginEmailController.text,
      onSuccess: (msg) => _showFeedback(msg),
    );
  }

  Future<void> _handleSubmitEmailAuth() async {
    setState(() => _isLoading = true);
    if (_isLogin) {
      await _saveRememberedEmail(
        _rememberEmail ? _loginEmailController.text : null,
      );
      if (!mounted) return;
      await _flowHandler.handleLogin(
        context: context,
        email: _loginEmailController.text,
        password: _loginPasswordController.text,
        onLockoutTicked: () {
          if (mounted) setState(() {});
        },
      );
    } else {
      final newCount = await _flowHandler.handleRegister(
        context: context,
        name: _registerNameController.text,
        email: _registerEmailController.text,
        career: _registerCareerController.text,
        gender: _registerGender,
        password: _registerPasswordController.text,
        confirmPassword: _registerConfirmPasswordController.text,
        createdAccountsOnDevice: _createdAccountsOnDevice,
        isCaptchaVerified: _isCaptchaVerified,
      );
      if (newCount != null && mounted) {
        setState(() => _createdAccountsOnDevice = newCount);
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  // Release controllers and resources to prevent memory leaks
  @override
  void dispose() {
    _lockoutManager.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerCareerController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  // Reactive widget tree rendering
  @override
  Widget build(BuildContext context) {
    final bool isLockoutActive = _isLogin && _lockoutManager.lockoutSeconds > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthHeaderWidget(isLogin: _isLogin),
                  const SizedBox(height: 24),
                  AuthModeSelector(
                    isLogin: _isLogin,
                    onModeChanged: (val) => setState(() => _isLogin = val),
                  ),
                  const SizedBox(height: 20),
                  if (isLockoutActive)
                    AuthLockoutBanner(
                      failedAttemptsCount: _lockoutManager.failedAttemptsCount,
                      lockoutSeconds: _lockoutManager.lockoutSeconds,
                    ),
                  if (_isLogin)
                    AuthLoginForm(
                      emailController: _loginEmailController,
                      passwordController: _loginPasswordController,
                      onForgotPassword: _handleOpenForgotPasswordDialog,
                      rememberEmail: _rememberEmail,
                      onRememberEmailChanged: _setRememberEmail,
                      onEmailChanged: _handleLoginEmailChanged,
                    )
                  else
                    AuthRegisterForm(
                      nameController: _registerNameController,
                      emailController: _registerEmailController,
                      careerController: _registerCareerController,
                      passwordController: _registerPasswordController,
                      confirmPasswordController:
                          _registerConfirmPasswordController,
                      selectedGender: _registerGender,
                      onGenderChanged: (val) =>
                          setState(() => _registerGender = val),
                      requireCaptcha: _createdAccountsOnDevice >= 1,
                      isCaptchaVerified: _isCaptchaVerified,
                      onCaptchaVerified: (val) =>
                          setState(() => _isCaptchaVerified = val),
                      onStateUpdate: () => setState(() {}),
                    ),
                  const SizedBox(height: 24),
                  AuthActionButtons(
                    isLogin: _isLogin,
                    isLoading: _isLoading,
                    isLockoutActive: isLockoutActive,
                    lockoutSeconds: _lockoutManager.lockoutSeconds,
                    onSubmitEmailAuth: _handleSubmitEmailAuth,
                    onGuestSignIn: TrialModeSession.start,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
