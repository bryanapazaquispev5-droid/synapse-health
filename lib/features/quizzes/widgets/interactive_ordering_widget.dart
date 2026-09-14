import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/quiz_model.dart';

/// Widget táctil de reordenamiento para preguntas de tipo "Para Ordenar"
/// Permite arrastrar elementos hacia arriba o abajo (o usar flechas de accesibilidad)
/// para disponer la secuencia anatómica correcta.
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

    // Desordenar inicialmente para que el usuario deba organizarlos
    if (shuffled.length > 1) {
      shuffled.shuffle(Random());
      // Asegurar que comience desordenado si hay 2 o más elementos
      if (_listsEqual(shuffled, _correctSequence)) {
        final first = shuffled.removeAt(0);
        shuffled.add(first);
      }
    }

    _currentItems = shuffled;
    _isSubmitted = widget.isAnswered;
  }

  bool _listsEqual(List<String> a, List<String> b) {
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

    final isCorrect = _listsEqual(_currentItems, _correctSequence);

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
        // Barra superior de instrucciones y botón de reiniciar
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

        // Lista reordenable táctil
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
            return _buildReorderableCard(item, index);
          },
        ),

        // Resumen de la secuencia anatómica correcta al verificar
        if (_isSubmitted) ...[
          const SizedBox(height: 12),
          _buildSequenceSummary(),
        ],

        // Botón para comprobar el orden propuesto
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

  Widget _buildReorderableCard(String item, int index) {
    final bool isCorrectPosition = _isSubmitted && _isItemInCorrectPosition(index);
    final bool isIncorrectPosition = _isSubmitted && !_isItemInCorrectPosition(index);

    Color bg = AppColors.surface;
    Color borderColor = AppColors.border;
    Color badgeBg = const Color(0xFFF2F2F7);
    Color badgeTextColor = AppColors.primary;
    double borderWidth = 1.0;

    if (isCorrectPosition) {
      bg = const Color(0xFFF0FDF4);
      borderColor = AppColors.systemGreen;
      badgeBg = AppColors.systemGreen;
      badgeTextColor = Colors.white;
      borderWidth = 1.6;
    } else if (isIncorrectPosition) {
      bg = const Color(0xFFFEF2F2);
      borderColor = AppColors.systemRed;
      badgeBg = AppColors.systemRed;
      badgeTextColor = Colors.white;
      borderWidth = 1.6;
    }

    return Container(
      key: ValueKey('$item-$index'),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            // Badge con el número de posición ordinal
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: isCorrectPosition
                  ? const Icon(CupertinoIcons.checkmark, color: Colors.white, size: 16)
                  : isIncorrectPosition
                      ? const Icon(CupertinoIcons.xmark, color: Colors.white, size: 16)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: badgeTextColor,
                          ),
                        ),
            ),
            const SizedBox(width: 12),

            // Texto descriptivo del elemento anatómico
            Expanded(
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  height: 1.35,
                ),
              ),
            ),

            // Controles de reordenamiento
            if (!_isSubmitted) ...[
              // Botones de accesibilidad arriba/abajo
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (index > 0)
                    GestureDetector(
                      onTap: () => _moveItem(index, -1),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                        child: Icon(CupertinoIcons.chevron_up, size: 16, color: AppColors.textMuted),
                      ),
                    ),
                  if (index < _currentItems.length - 1)
                    GestureDetector(
                      onTap: () => _moveItem(index, 1),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                        child: Icon(CupertinoIcons.chevron_down, size: 16, color: AppColors.textMuted),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 4),

              // Agarradera táctil de arrastre (Drag Handle)
              ReorderableDragStartListener(
                index: index,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    CupertinoIcons.bars,
                    size: 18,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSequenceSummary() {
    final bool allCorrect = _listsEqual(_currentItems, _correctSequence);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                allCorrect ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.compass_fill,
                size: 16,
                color: allCorrect ? AppColors.systemGreen : AppColors.accent,
              ),
              const SizedBox(width: 6),
              Text(
                allCorrect ? '¡Secuencia Exacta!' : 'Secuencia Anatómica Canónica',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: allCorrect ? AppColors.systemGreen : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...List.generate(_correctSequence.length, (i) {
            final correctItem = _correctSequence[i];
            final userItem = i < _currentItems.length ? _currentItems[i] : '';
            final isMatch = userItem == correctItem;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isMatch ? AppColors.systemGreen : const Color(0xFFE5E5EA),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isMatch ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      correctItem,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isMatch ? FontWeight.w700 : FontWeight.w500,
                        color: isMatch ? AppColors.systemGreen : AppColors.primary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
