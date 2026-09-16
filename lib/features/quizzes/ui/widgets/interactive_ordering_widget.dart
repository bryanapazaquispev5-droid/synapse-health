import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../model/quiz_model.dart';
import 'ordering_reorderable_card.dart';
import 'ordering_sequence_summary.dart';

/// Widget táctil de reordenamiento para preguntas de tipo "Para Ordenar"
class InteractiveOrderingWidget extends StatefulWidget {
  final QuizModel quiz;
  final bool isAnswered;
  final ValueChanged<bool> onCompleted;

  const InteractiveOrderingWidget({
    super.key,
    required this.quiz,
    required this.isAnswered,
    required this.onCompleted,
  });

  @override
  State<InteractiveOrderingWidget> createState() => _InteractiveOrderingWidgetState();
}

class _InteractiveOrderingWidgetState extends State<InteractiveOrderingWidget> {
  late List<String> _correctSequence;
  late List<String> _currentItems;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _initItems();
  }

  @override
  void didUpdateWidget(covariant InteractiveOrderingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quiz.id != widget.quiz.id) {
      _initItems();
    }
  }

  void _initItems() {
    _correctSequence = List.from(widget.quiz.orderingItems);
    final shuffled = List<String>.from(_correctSequence);

    if (shuffled.length > 1) {
      shuffled.shuffle(Random());
      if (_areListsEqual(shuffled, _correctSequence)) {
        final first = shuffled.removeAt(0);
        shuffled.add(first);
      }
    }

    _currentItems = shuffled;
    _isSubmitted = widget.isAnswered;
  }

  bool _areListsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _moveItem(int index, int delta) {
    if (_isSubmitted) return;
    final newIndex = index + delta;
    if (newIndex < 0 || newIndex >= _currentItems.length) return;

    setState(() {
      final item = _currentItems.removeAt(index);
      _currentItems.insert(newIndex, item);
    });
  }

  void _resetOrder() {
    if (_isSubmitted) return;
    setState(() {
      _initItems();
    });
  }

  void _checkOrder() {
    if (_isSubmitted) return;

    final isCorrect = _areListsEqual(_currentItems, _correctSequence);

    setState(() {
      _isSubmitted = true;
    });

    widget.onCompleted(isCorrect);
  }

  bool _isItemInCorrectPosition(int index) {
    if (index >= _correctSequence.length) return false;
    return _currentItems[index] == _correctSequence[index];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(CupertinoIcons.arrow_up_arrow_down, size: 13, color: AppColors.accent),
                  SizedBox(width: 5),
                  Text(
                    'Arrastra arriba o abajo para ordenar',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
            if (!_isSubmitted)
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                onPressed: _resetOrder,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(CupertinoIcons.arrow_counterclockwise, size: 12, color: AppColors.textMuted),
                    SizedBox(width: 4),
                    Text(
                      'Desordenar',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _currentItems.length,
          onReorderItem: (oldIndex, newIndex) {
            if (_isSubmitted) return;
            setState(() {
              final item = _currentItems.removeAt(oldIndex);
              _currentItems.insert(newIndex, item);
            });
          },
          buildDefaultDragHandles: false,
          proxyDecorator: (child, index, animation) {
            return Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
          itemBuilder: (context, index) {
            final item = _currentItems[index];
            final int originIndex = _correctSequence.indexOf(item);
            return OrderingReorderableCard(
              key: ValueKey('order_card_${item}_$originIndex'),
              item: item,
              index: index,
              totalItems: _currentItems.length,
              isSubmitted: _isSubmitted,
              isCorrectPosition: _isSubmitted && _isItemInCorrectPosition(index),
              isIncorrectPosition: _isSubmitted && !_isItemInCorrectPosition(index),
              onMoveItem: _moveItem,
            );
          },
        ),
        if (_isSubmitted) ...[
          const SizedBox(height: 12),
          OrderingSequenceSummary(
            correctSequence: _correctSequence,
            currentItems: _currentItems,
          ),
        ],
        if (!_isSubmitted) ...[
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: CupertinoButton(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(14),
              onPressed: _checkOrder,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(CupertinoIcons.checkmark_alt_circle_fill, size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Comprobar Secuencia',
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
        ],
      ],
    );
  }
}
