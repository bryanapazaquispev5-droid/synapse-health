import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';

class GenderSelectorWidget extends StatelessWidget {
  final String selectedGender;
  final ValueChanged<String> onGenderChanged;

  const GenderSelectorWidget({
    super.key,
    required this.selectedGender,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 2, bottom: 8),
            child: Text(
              'Género del Estudiante',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<String>(
              groupValue: selectedGender,
              backgroundColor: const Color(0xFFF1F5F9),
              thumbColor: AppColors.surface,
              padding: const EdgeInsets.all(4),
              children: const {
                'Hombre': Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.person_fill, size: 16, color: AppColors.primary),
                      SizedBox(width: 6),
                      Text('Hombre', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ],
                  ),
                ),
                'Mujer': Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.person_alt, size: 16, color: AppColors.primary),
                      SizedBox(width: 6),
                      Text('Mujer', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ],
                  ),
                ),
              },
              onValueChanged: (val) {
                if (val != null) onGenderChanged(val);
              },
            ),
          ),
        ],
      ),
    );
  }
}
