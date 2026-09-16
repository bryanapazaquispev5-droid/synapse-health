import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';

class CompleteProfileHeader extends StatelessWidget {
  final VoidCallback onCancel;

  const CompleteProfileHeader({super.key, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onCancel,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(CupertinoIcons.chevron_back, size: 20, color: AppColors.textMuted),
                  SizedBox(width: 4),
                  Text(
                    'Cancelar',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Paso Final',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            CupertinoIcons.person_crop_circle_badge_checkmark,
            size: 36,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Completa tu Perfil',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Personaliza tu experiencia médica indicando tu carrera y preferencias',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textMuted,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
