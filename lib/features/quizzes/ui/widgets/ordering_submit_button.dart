// ============================================================================
// File: ordering_submit_button.dart
// Purpose: Action button for checking the ordered sequence in ordering quizzes.
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// Main definition of the class [OrderingSubmitButton]
class OrderingSubmitButton extends StatelessWidget {
  final VoidCallback onCheckOrder;

  const OrderingSubmitButton({
    super.key,
    required this.onCheckOrder,
  });

  // Reactive rendering of the widget tree
  // Block: Reactive rendering of the main widget tree
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: CupertinoButton(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(14),
          onPressed: onCheckOrder,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                CupertinoIcons.checkmark_alt_circle_fill,
                size: 18,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                'Check Sequence',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
