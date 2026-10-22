import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../api/cognito_auth_service.dart';
import '../model/cognito_auth_exception.dart';
import '../model/cognito_session.dart';
import 'cognito_auth_form.dart';
import 'cognito_session_panel.dart';

/// Opt-in transition UI. A Cognito identity never becomes a Firebase User.
class CognitoAuthScreen extends StatefulWidget {
  const CognitoAuthScreen({super.key, required this.service, this.onUseFirebase});
  final CognitoAuthService service;
  final VoidCallback? onUseFirebase;
  @override
  State<CognitoAuthScreen> createState() => _CognitoAuthScreenState();
}

class _CognitoAuthScreenState extends State<CognitoAuthScreen> with WidgetsBindingObserver {
  final _email = TextEditingController(), _password = TextEditingController();
  final _name = TextEditingController(), _code = TextEditingController();
  var _step = CognitoFormStep.credentials;
  bool _isLogin = true, _busy = false, _restoring = true;
  String? _message;
  StreamSubscription<CognitoSession?>? _subscription;
  CognitoSession? _session;
  Timer? _expiryTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _acceptSession(widget.service.currentSession);
    _subscription = widget.service.sessionChanges.listen(_acceptSession);
    unawaited(
      _run(() async {
        _acceptSession(await widget.service.restoreSession());
      }).whenComplete(() {
        if (mounted) {
          setState(() => _restoring = false);
        }
      }),
    );
  }

  void _acceptSession(CognitoSession? session) {
    _expiryTimer?.cancel();
    if (!mounted) {
      return;
    }
    setState(() => _session = session);
    if (session != null) {
      _password.clear();
      _code.clear();
      final delay = session.expiresAt.difference(DateTime.now());
      _expiryTimer = Timer(
        delay.isNegative ? Duration.zero : delay,
        () => _run(() async {
          await widget.service.validSession();
        }),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.service.currentSession != null) {
      unawaited(
        _run(() async {
          await widget.service.validSession();
        }),
      );
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) {
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
    } on CognitoAuthException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _message = error.message;
        if (error.code == 'confirmation_required') {
          _step = CognitoFormStep.confirmation;
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() => _message = 'No se pudo completar la solicitud. Inténtalo nuevamente.');
      }
    } finally {
      if (mounted) {
        _password.clear();
        _code.clear();
        setState(() {
          _busy = false;
          if (_session != null && !_session!.expiresAt.isAfter(DateTime.now())) {
            _session = null;
          }
        });
      }
    }
  }

  Future<void> _submit() => _run(() async {
    final email = _email.text.trim();
    switch (_step) {
      case CognitoFormStep.credentials:
        if (_isLogin) {
          await widget.service.signIn(email: email, password: _password.text);
        } else {
          await widget.service.register(email: email, password: _password.text, name: _name.text.trim());
          if (mounted) {
            setState(() {
              _step = CognitoFormStep.confirmation;
              _message = 'Revisa tu correo para confirmar la cuenta.';
            });
          }
        }
      case CognitoFormStep.confirmation:
        await widget.service.confirmRegistration(email: email, code: _code.text.trim());
        if (mounted) {
          setState(() {
            _step = CognitoFormStep.credentials;
            _isLogin = true;
            _message = 'Correo confirmado. Ya puedes iniciar sesión.';
          });
        }
      case CognitoFormStep.resetRequest:
        await widget.service.forgotPassword(email);
        if (mounted) {
          setState(() {
            _step = CognitoFormStep.resetCode;
            _message = 'Si la cuenta permite recuperación, recibirás un código.';
          });
        }
      case CognitoFormStep.resetCode:
        await widget.service.confirmPasswordReset(email: email, code: _code.text.trim(), newPassword: _password.text);
        if (mounted) {
          setState(() {
            _step = CognitoFormStep.credentials;
            _isLogin = true;
            _message = 'Contraseña restablecida. Inicia sesión nuevamente.';
          });
        }
    }
  });

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _expiryTimer?.cancel();
    unawaited(_subscription?.cancel());
    for (final controller in [_email, _password, _name, _code]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: _restoring
        ? const Center(child: CupertinoActivityIndicator())
        : SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_session == null)
                        IgnorePointer(
                          ignoring: _busy,
                          child: CognitoAuthForm(
                            step: _step,
                            isLogin: _isLogin,
                            email: _email,
                            password: _password,
                            name: _name,
                            code: _code,
                            busy: _busy,
                            onMode: (value) => setState(() {
                              _isLogin = value;
                              _message = null;
                            }),
                            onForgot: () => setState(() => _step = CognitoFormStep.resetRequest),
                            onSubmit: _submit,
                            onBack: () => setState(() {
                              _step = CognitoFormStep.credentials;
                              _isLogin = true;
                              _message = null;
                            }),
                            onResend: () => _run(() async {
                              await widget.service.resendConfirmation(_email.text.trim());
                              if (mounted) {
                                setState(() => _message = 'Revisa tu correo para obtener el código.');
                              }
                            }),
                          ),
                        )
                      else
                        CognitoSessionPanel(
                          busy: _busy,
                          onSignOut: () => _run(() async {
                            final result = await widget.service.signOut();
                            if (mounted && !result.remoteRevoked) {
                              setState(
                                () => _message = 'Sesión local cerrada. No se pudo confirmar la revocación remota.',
                              );
                            }
                          }),
                        ),
                      if (widget.onUseFirebase != null)
                        CupertinoButton(
                          onPressed: _busy ? null : widget.onUseFirebase,
                          child: const Text('Continuar con Firebase'),
                        ),
                      if (_message != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Semantics(
                            liveRegion: true,
                            child: Text(_message!, style: const TextStyle(color: AppColors.primary)),
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
