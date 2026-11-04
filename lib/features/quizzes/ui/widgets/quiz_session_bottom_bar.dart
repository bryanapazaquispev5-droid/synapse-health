// ============================================================================
// File: quiz_session_bottom_bar.dart
// Purpose: State controller and presenter for the interactive medical quiz session.
// ============================================================================

import 'package:flutter/cupertino.dart';

// Modular visual component [QuizSessionBottomBar]
class QuizSessionBottomBar extends StatelessWidget {
  final bool hasNext;
  final VoidCallback onNext;

  const QuizSessionBottomBar({
    super.key,
    required this.hasNext,
    required this.onNext,
  });

  // Reactive rendering of the widget tree
  // Block: Reactive rendering of the main widget tree
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      height: 52,
      child: CupertinoButton.filled(
        borderRadius: BorderRadius.circular(16),
        onPressed: onNext,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              hasNext ? 'Next Question' : 'View Final Results',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(CupertinoIcons.arrow_right, size: 18),
          ],
        ),
      ),
    );
  }
}
