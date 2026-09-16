import 'package:flutter/material.dart';
import 'matching_left_card.dart';
import 'matching_right_card.dart';

class MatchingRowItem extends StatelessWidget {
  final int index;
  final String leftText;
  final bool isLeftSelected;
  final bool isLeftPaired;
  final int? leftPairNum;
  final Color pairColor;
  final bool isLeftCorrect;
  final bool isLeftIncorrect;
  final VoidCallback onLeftTap;

  final int? rightIndex;
  final String? rightText;
  final bool isRightPaired;
  final int? rightPairNum;
  final Color rightPairColor;
  final bool isTargetOfSelected;
  final bool isSubmitted;
  final bool isRightCorrect;
  final bool isRightIncorrect;
  final VoidCallback onRightTap;

  const MatchingRowItem({
    super.key,
    required this.index,
    required this.leftText,
    required this.isLeftSelected,
    required this.isLeftPaired,
    required this.leftPairNum,
    required this.pairColor,
    required this.isLeftCorrect,
    required this.isLeftIncorrect,
    required this.onLeftTap,
    required this.rightIndex,
    required this.rightText,
    required this.isRightPaired,
    required this.rightPairNum,
    required this.rightPairColor,
    required this.isTargetOfSelected,
    required this.isSubmitted,
    required this.isRightCorrect,
    required this.isRightIncorrect,
    required this.onRightTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: MatchingLeftCard(
                index: index,
                text: leftText,
                isSelected: isLeftSelected,
                isPaired: isLeftPaired,
                pairNumber: leftPairNum,
                pairColor: pairColor,
                isCorrect: isLeftCorrect,
                isIncorrect: isLeftIncorrect,
                onTap: onLeftTap,
              ),
            ),
            const SizedBox(width: 10),
            if (rightText != null && rightIndex != null)
              Expanded(
                child: MatchingRightCard(
                  rightIndex: rightIndex!,
                  text: rightText!,
                  isPaired: isRightPaired,
                  pairNumber: rightPairNum,
                  pairColor: rightPairColor,
                  isTargetOfSelected: isTargetOfSelected,
                  isSubmitted: isSubmitted,
                  isCorrect: isRightCorrect,
                  isIncorrect: isRightIncorrect,
                  onTap: onRightTap,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
