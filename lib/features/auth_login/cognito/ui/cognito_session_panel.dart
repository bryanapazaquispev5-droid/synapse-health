import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_theme.dart';

class CognitoSessionPanel extends StatelessWidget {
  const CognitoSessionPanel({super.key, required this.busy, required this.onSignOut});
  final bool busy;
  final VoidCallback onSignOut;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        'Sesión Cognito',
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.primary),
      ),
      const SizedBox(height: 16),
      const Text(
        'Autenticación completada en el entorno de transición. '
        'Tus datos académicos continúan en Firebase.',
      ),
      const SizedBox(height: 24),
      CupertinoButton.filled(
        onPressed: busy ? null : onSignOut,
        child: busy
            ? const CupertinoActivityIndicator(color: AppColors.surface)
            : const Text('Cerrar sesión'),
      ),
    ],
  );
}
