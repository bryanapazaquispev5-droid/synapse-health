import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../model/quiz_model.dart';
import '../../utils/matching_state_helper.dart';
import 'matching_header_controls.dart';
import 'matching_row_item.dart';
import 'matching_solutions_summary.dart';
import 'matching_submit_button.dart';

/// Widget interactivo de dos columnas para Quizzes anatómicos de tipo "Para Relacionar"
class InteractiveMatchingWidget extends StatefulWidget {
  final QuizModel quiz;
  final bool isAnswered;
  final ValueChanged<bool> onCompleted;

  const InteractiveMatchingWidget({
    super.key,
    required this.quiz,
    required this.isAnswered,
    required this.onCompleted,
  });

  @override
  State<InteractiveMatchingWidget> createState() => _InteractiveMatchingWidgetState();
}

class _InteractiveMatchingWidgetState extends State<InteractiveMatchingWidget> {
  late List<MatchingPair> _originalPairs;
  late List<String> _leftItems;
  late List<String> _rightItems;

  final Map<int, int> _userPairings = {};
  int? _selectedLeftIndex;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _initPairs();
  }

  @override
  void didUpdateWidget(covariant InteractiveMatchingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quiz.id != widget.quiz.id) {
      _initPairs();
    }
  }

  void _initPairs() {
    _originalPairs = List.from(widget.quiz.matchingPairs);
    _leftItems = _originalPairs.map((p) => p.left).toList();

    final shuffledRights = _originalPairs.map((p) => p.right).toList();
    shuffledRights.shuffle(Random());
    if (shuffledRights.length > 1 && _areArraysEqual(shuffledRights, _originalPairs.map((p) => p.right).toList())) {
      final first = shuffledRights.removeAt(0);
      shuffledRights.add(first);
    }
    _rightItems = shuffledRights;

    _userPairings.clear();
    _selectedLeftIndex = null;
    _isSubmitted = widget.isAnswered;
  }

  bool _areArraysEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _onLeftItemTapped(int index) {
    if (_isSubmitted) return;
    setState(() {
      _selectedLeftIndex = (_selectedLeftIndex == index) ? null : index;
    });
  }

  void _onRightItemTapped(int rightIndex) {
    if (_isSubmitted) return;

    if (_selectedLeftIndex == null) {
      final existingLeft = MatchingStateHelper.getLeftIndexForRight(_userPairings, rightIndex);
      if (existingLeft != null) {
        setState(() => _selectedLeftIndex = existingLeft);
      }
      return;
    }

    setState(() {
      final currentLeft = _selectedLeftIndex!;
      _userPairings.removeWhere((l, r) => r == rightIndex);
      _userPairings[currentLeft] = rightIndex;

      _selectedLeftIndex = null;
      for (int i = 0; i < _leftItems.length; i++) {
        if (!_userPairings.containsKey(i)) {
          _selectedLeftIndex = i;
          break;
        }
      }
    });
  }

  void _resetPairings() {
    if (_isSubmitted) return;
    setState(() {
      _userPairings.clear();
      _selectedLeftIndex = 0;
    });
  }

  void _checkAnswers() {
    if (_userPairings.length < _leftItems.length || _isSubmitted) return;

    bool isAllCorrect = true;
    for (final entry in _userPairings.entries) {
      final leftText = _leftItems[entry.key];
      final userRightText = _rightItems[entry.value];

      final pair = _originalPairs.firstWhere(
        (p) => p.left == leftText,
        orElse: () => const MatchingPair(left: '', right: ''),
      );

      if (pair.right != userRightText) {
        isAllCorrect = false;
      }
    }

    setState(() {
      _isSubmitted = true;
      _selectedLeftIndex = null;
    });

    widget.onCompleted(isAllCorrect);
  }

  bool _isPairCorrect(int? leftIndex) {
    return MatchingStateHelper.isPairCorrect(
      userPairings: _userPairings,
      leftItems: _leftItems,
      rightItems: _rightItems,
      originalPairs: _originalPairs,
      leftIndex: leftIndex,
    );
  }

  Widget _buildMatchingRow(int index) {
    final leftText = _leftItems[index];
    final isLeftSelected = _selectedLeftIndex == index;
    final isLeftPaired = _userPairings.containsKey(index);
    final leftPairNum = MatchingStateHelper.getPairNumberForLeft(_userPairings, index);
    final pairColor = leftPairNum != null ? MatchingStateHelper.getPairColor(leftPairNum - 1) : AppColors.accent;

    final rightIndex = index < _rightItems.length ? index : null;
    final rightText = rightIndex != null ? _rightItems[rightIndex] : null;
    final rightLeftIndex = rightIndex != null ? MatchingStateHelper.getLeftIndexForRight(_userPairings, rightIndex) : null;
    final isRightPaired = rightLeftIndex != null;
    final rightPairNum = rightIndex != null ? MatchingStateHelper.getPairNumberForRight(_userPairings, rightIndex) : null;
    final rightPairColor = rightPairNum != null ? MatchingStateHelper.getPairColor(rightPairNum - 1) : AppColors.accent;

    final isSubmitted = _isSubmitted;
    final bool isLeftCorrect = isSubmitted && isLeftPaired && _isPairCorrect(index);
    final bool isLeftIncorrect = isSubmitted && isLeftPaired && !_isPairCorrect(index);
    final bool isRightCorrect = isSubmitted && isRightPaired && _isPairCorrect(rightLeftIndex);
    final bool isRightIncorrect = isSubmitted && isRightPaired && !_isPairCorrect(rightLeftIndex);

    return MatchingRowItem(
      index: index,
      leftText: leftText,
      isLeftSelected: isLeftSelected,
      isLeftPaired: isLeftPaired,
      leftPairNum: leftPairNum,
      pairColor: pairColor,
      isLeftCorrect: isLeftCorrect,
      isLeftIncorrect: isLeftIncorrect,
      onLeftTap: () => _onLeftItemTapped(index),
      rightIndex: rightIndex,
      rightText: rightText,
      isRightPaired: isRightPaired,
      rightPairNum: rightPairNum,
      rightPairColor: rightPairColor,
      isTargetOfSelected: isLeftSelected,
      isSubmitted: isSubmitted,
      isRightCorrect: isRightCorrect,
      isRightIncorrect: isRightIncorrect,
      onRightTap: () => rightIndex != null ? _onRightItemTapped(rightIndex) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAllPaired = _userPairings.length == _leftItems.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MatchingHeaderControls(
          isSubmitted: _isSubmitted,
          hasPairings: _userPairings.isNotEmpty,
          onReset: _resetPairings,
        ),
        const SizedBox(height: 12),
        ...List.generate(_leftItems.length, _buildMatchingRow),
        if (_isSubmitted)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: MatchingSolutionsSummary(
              leftItems: _leftItems,
              rightItems: _rightItems,
              originalPairs: _originalPairs,
              userPairings: _userPairings,
            ),
          ),
        if (!_isSubmitted)
          MatchingSubmitButton(
            isAllPaired: isAllPaired,
            pairedCount: _userPairings.length,
            totalCount: _leftItems.length,
            onCheckAnswers: _checkAnswers,
          ),
      ],
    );
  }
}
