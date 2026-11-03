import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../utils/career_options.dart';

class CareerDropdownField extends StatelessWidget {
  const CareerDropdownField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.only(left: 4, bottom: 6),
        child: Text(
          'Degree or Specialty',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(CupertinoIcons.book, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: careerOptions.contains(controller.text)
                      ? controller.text
                      : null,
                  isExpanded: true,
                  hint: const Text('Select your degree or specialty'),
                  items: careerOptions
                      .map(
                        (career) => DropdownMenuItem(
                          value: career,
                          child: Text(career),
                        ),
                      )
                      .toList(),
                  onChanged: (career) {
                    if (career == null) return;
                    controller.text = career;
                    onChanged();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
