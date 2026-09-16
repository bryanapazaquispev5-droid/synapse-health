import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';
import 'opaque_action_sheet.dart';

class ProfileCareerSheet {
  static const List<Map<String, dynamic>> careers = [
    {'title': 'Medicina Humana', 'icon': CupertinoIcons.heart_fill, 'color': AppColors.systemRed},
    {'title': 'Enfermería', 'icon': CupertinoIcons.bandage_fill, 'color': AppColors.systemTeal},
    {'title': 'Odontología', 'icon': CupertinoIcons.sparkles, 'color': AppColors.systemIndigo},
    {'title': 'Farmacia y Bioquímica', 'icon': CupertinoIcons.lab_flask_solid, 'color': AppColors.systemGreen},
    {'title': 'Obstetricia', 'icon': CupertinoIcons.person_crop_circle_badge_checkmark, 'color': AppColors.systemPink},
    {'title': 'Nutrición', 'icon': CupertinoIcons.leaf_arrow_circlepath, 'color': AppColors.systemOrange},
  ];

  static void show({
    required BuildContext context,
    required String currentCareer,
    required ValueChanged<String> onSelectCareer,
  }) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: const Color(0x5A000000),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, animation, secondaryAnimation) {
        return OpaqueActionSheet(
          title: const Text(
            'Especialidad o Carrera',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              decoration: TextDecoration.none,
            ),
          ),
          message: const Text(
            'Selecciona tu área de formación en salud:',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 13,
              fontWeight: FontWeight.normal,
              color: AppColors.textMuted,
              decoration: TextDecoration.none,
            ),
          ),
          actions: [
            ...careers.map((c) {
              final String title = c['title'] as String;
              final IconData icon = c['icon'] as IconData;
              final Color color = c['color'] as Color;
              final bool isSelected = currentCareer.trim().toLowerCase() == title.toLowerCase();

              return OpaqueActionSheetActionItem(
                onPressed: () {
                  Navigator.pop(context);
                  onSelectCareer(title);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: color, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.accent : AppColors.primary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 6),
                      const Icon(CupertinoIcons.checkmark_alt, size: 16, color: AppColors.accent),
                    ],
                  ],
                ),
              );
            }),
            OpaqueActionSheetActionItem(
              onPressed: () {
                Navigator.pop(context);
                _openCustomCareerDialog(context, currentCareer, onSelectCareer);
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.pencil_ellipsis_rectangle, color: AppColors.textMuted, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Otra especialidad...',
                    style: TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accent,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(curvedAnimation),
          child: Align(alignment: Alignment.bottomCenter, child: child),
        );
      },
    );
  }

  static void _openCustomCareerDialog(
    BuildContext context,
    String currentCareer,
    ValueChanged<String> onSelectCareer,
  ) {
    final controller = TextEditingController(text: currentCareer);
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Dismiss',
      barrierColor: const Color(0x33000000),
      transitionDuration: const Duration(milliseconds: 520),
      pageBuilder: (context, animation, secondaryAnimation) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        final offsetY = bottomInset > 0 ? 100.0 : 0.0;
        return Transform.translate(
          offset: Offset(0, offsetY),
          child: Opacity(
            opacity: 0.90,
            child: CupertinoAlertDialog(
              title: const Text(
                'Otra Especialidad',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.4),
              ),
              content: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Escribe tu carrera médica o especialidad:',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 12),
                    CupertinoTextField(
                      controller: controller,
                      autofocus: false,
                      textCapitalization: TextCapitalization.words,
                      placeholder: 'Ej: Cardiología, Pediatría...',
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: const Color(0xFFD1D1D6), width: 0.8),
                      ),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
                ),
                CupertinoDialogAction(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isEmpty) return;
                    Navigator.pop(context);
                    onSelectCareer(text);
                  },
                  child: const Text('Guardar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.accent)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
