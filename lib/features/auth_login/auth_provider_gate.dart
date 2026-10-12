import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/states/app_states.dart';
import 'cognito/api/cognito_auth_service.dart';
import 'cognito/model/cognito_config.dart';
import 'cognito/ui/cognito_auth_screen.dart';

typedef CognitoScreenBuilder = Widget Function(VoidCallback useFirebase);

/// Explicit staging boundary. Production keeps the existing Firebase provider.
class AuthProviderGate extends StatefulWidget {
  const AuthProviderGate({
    super.key,
    required this.firebaseChild,
    this.provider = CognitoConfig.provider,
    this.stagingEnabled = const bool.fromEnvironment('SYNAPSE_COGNITO_STAGING'),
    this.isRelease = kReleaseMode,
    this.cognitoBuilder,
  });
  final Widget firebaseChild;
  final String provider;
  final bool stagingEnabled;
  final bool isRelease;
  final CognitoScreenBuilder? cognitoBuilder;
  @override
  State<AuthProviderGate> createState() => _AuthProviderGateState();
}

class _AuthProviderGateState extends State<AuthProviderGate> {
  CognitoAuthService? _service;
  bool _useFirebase = false;
  bool _switching = false;
  bool _storageFailure = false;
  void _fallback() async {
    if (_switching) return;
    _switching = true;
    try {
      await _service?.signOut();
      if (mounted) setState(() => _useFirebase = true);
    } catch (_) {
      if (mounted) setState(() => _storageFailure = true);
    } finally {
      _switching = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_useFirebase || widget.provider == 'firebase') {
      return widget.firebaseChild;
    }
    if (_storageFailure ||
        widget.provider != 'cognito' ||
        !widget.stagingEnabled ||
        widget.isRelease) {
      return _unavailable();
    }
    if (widget.cognitoBuilder != null) return widget.cognitoBuilder!(_fallback);
    final config = CognitoConfig.fromEnvironment();
    if (!config.isValid) return _unavailable();
    _service ??= CognitoAuthService(config: config);
    return CognitoAuthScreen(service: _service!, onUseFirebase: _fallback);
  }

  Widget _unavailable() => CupertinoPageScaffold(
    backgroundColor: AppColors.background,
    child: SafeArea(
      child: Column(
        children: [
          const Expanded(
            child: AppErrorState(message: 'Acceso de prueba no disponible.'),
          ),
          CupertinoButton(
            onPressed: _fallback,
            child: const Text('Continuar con Firebase'),
          ),
        ],
      ),
    ),
  );
  @override
  void dispose() {
    _service?.dispose();
    super.dispose();
  }
}
