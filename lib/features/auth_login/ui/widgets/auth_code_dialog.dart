import 'package:flutter/material.dart';

import '../../../../core/auth/app_auth.dart';
import '../../utils/auth_validators.dart';

/// Confirmation and reset codes stay in memory only and are never logged.
class AuthCodeDialog extends StatefulWidget {
  const AuthCodeDialog({
    super.key,
    required this.email,
    required this.onSubmit,
    this.onResend,
    this.isReset = false,
    this.isEmailVerification = false,
  });
  final String email;
  final Future<void> Function(String code, String password) onSubmit;
  final Future<void> Function()? onResend;
  final bool isReset;
  final bool isEmailVerification;

  static Future<bool> show(
    BuildContext context, {
    required String email,
    required Future<void> Function(String code, String password) onSubmit,
    Future<void> Function()? onResend,
    bool isReset = false,
    bool isEmailVerification = false,
  }) async =>
      await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AuthCodeDialog(
          email: email,
          onSubmit: onSubmit,
          onResend: onResend,
          isReset: isReset,
          isEmailVerification: isEmailVerification,
        ),
      ) ??
      false;

  @override
  State<AuthCodeDialog> createState() => _AuthCodeDialogState();
}

class _AuthCodeDialogState extends State<AuthCodeDialog> {
  final _code = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!RegExp(r'^\d{6}$').hasMatch(_code.text.trim())) {
      setState(() => _error = 'Enter the six-digit code.');
      return;
    }
    if (widget.isReset &&
        !AuthValidators.meetsCognitoPasswordPolicy(_password.text)) {
      setState(
        () => _error = 'Use 12 characters, including an uppercase letter, a lowercase letter, a number, and a symbol.',
      );
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await widget.onSubmit(_code.text.trim(), _password.text);
      if (mounted) Navigator.pop(context, true);
    } on AppAuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = widget.isEmailVerification
              ? 'Could not verify your email. Try again.'
              : 'Could not confirm. Try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resend() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await widget.onResend!();
      if (mounted) {
        setState(
          () => _error = 'A new code will be sent if your account is eligible.',
        );
      }
    } on AppAuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_isLoading,
    child: AlertDialog(
      title: Text(
        widget.isReset
            ? 'Reset password'
            : widget.isEmailVerification
            ? 'Verify your email'
            : 'Confirm your email',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter the code sent to ${widget.email}.'),
            const SizedBox(height: 12),
            TextField(
              controller: _code,
              keyboardType: TextInputType.number,
              maxLength: 6,
              autofillHints: const [AutofillHints.oneTimeCode],
              decoration: const InputDecoration(labelText: 'Code'),
              enabled: !_isLoading,
            ),
            if (widget.isReset)
              TextField(
                controller: _password,
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                decoration: const InputDecoration(labelText: 'New password'),
                enabled: !_isLoading,
              ),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        if (widget.onResend != null)
          TextButton(
            onPressed: _isLoading ? null : _resend,
            child: const Text('Resend code'),
          ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: Text(
            _isLoading
                ? widget.isEmailVerification
                      ? 'Verifying…'
                      : 'Confirming…'
                : widget.isEmailVerification
                ? 'Verify'
                : 'Confirm',
          ),
        ),
      ],
    ),
  );
}
