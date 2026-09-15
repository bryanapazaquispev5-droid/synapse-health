import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/quiz_model.dart';

/// Widget interactivo de dos columnas para Quizzes anatómicos de tipo "Para Relacionar"
/// Permite tocar un elemento de la izquierda y emparejarlo con su correspondiente en la derecha.
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

  // Mapa de emparejamiento: leftIndex -> rightIndex
  final Map<int, int> _userPairings = {};
  int? _selectedLeftIndex;
  bool _isSubmitted = false;

  // Paleta de colores distintivos Apple HIG para cada par emparejado
  static const List<Color> _pairColors = [
    Color(0xFF007AFF), // iOS Blue
    Color(0xFF5856D6), // iOS Indigo / Purple
    Color(0xFFFF9500), // iOS Orange
    Color(0xFF30B0C7), // iOS Teal
    Color(0xFFAF52DE), // iOS Violet
    Color(0xFFFF2D55), // iOS Pink
  ];

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

    // Desordenar los elementos de la derecha de forma aleatoria controlada
    final shuffledRights = _originalPairs.map((p) => p.right).toList();
    shuffledRights.shuffle(Random());
    // Asegurar que si hay más de 1 elemento, no queden en el mismo orden original si es posible
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

  Color _getPairColor(int pairIndex) {
    return _pairColors[pairIndex % _pairColors.length];
  }

  int? _getPairNumberForLeft(int leftIndex) {
    if (!_userPairings.containsKey(leftIndex)) return null;
    final keys = _userPairings.keys.toList()..sort();
    return keys.indexOf(leftIndex) + 1;
  }

  int? _getPairNumberForRight(int rightIndex) {
    for (final entry in _userPairings.entries) {
      if (entry.value == rightIndex) {
        return _getPairNumberForLeft(entry.key);
      }
    }
    return null;
  }

  int? _getLeftIndexForRight(int rightIndex) {
    for (final entry in _userPairings.entries) {
      if (entry.value == rightIndex) return entry.key;
    }
    return null;
  }

  void _onLeftItemTapped(int index) {
    if (_isSubmitted) return;

    setState(() {
      if (_selectedLeftIndex == index) {
        // Deseleccionar si ya estaba seleccionado
        _selectedLeftIndex = null;
      } else {
        _selectedLeftIndex = index;
      }
    });
  }

  void _onRightItemTapped(int rightIndex) {
    if (_isSubmitted) return;

    if (_selectedLeftIndex == null) {
      // Si tocó la derecha pero ya estaba emparejado, selecciona ese izquierdo para fácil reasignación
      final existingLeft = _getLeftIndexForRight(rightIndex);
      if (existingLeft != null) {
        setState(() {
          _selectedLeftIndex = existingLeft;
        });
      }
      return;
    }

    setState(() {
      final currentLeft = _selectedLeftIndex!;

      // Si otro izquierdo ya tenía este elemento derecho, se lo quitamos
      _userPairings.removeWhere((l, r) => r == rightIndex);

      // Asignar nueva relación
      _userPairings[currentLeft] = rightIndex;

      // Avanzar al siguiente izquierdo no emparejado si existe
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

  bool _isPairCorrect(int leftIndex) {
    final rightIndex = _userPairings[leftIndex];
    if (rightIndex == null) return false;

    final leftText = _leftItems[leftIndex];
    final userRightText = _rightItems[rightIndex];

    final pair = _originalPairs.firstWhere(
      (p) => p.left == leftText,
      orElse: () => const MatchingPair(left: '', right: ''),
    );

    return pair.right == userRightText;
  }

  String _getCorrectRightTextForLeft(int leftIndex) {
    final leftText = _leftItems[leftIndex];
    final pair = _originalPairs.firstWhere(
      (p) => p.left == leftText,
      orElse: () => const MatchingPair(left: '', right: ''),
    );
    return pair.right;
  }

  @override
  Widget build(BuildContext context) {
    final bool isAllPaired = _userPairings.length == _leftItems.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Barra de instrucciones y botón de restablecer
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
                  Icon(CupertinoIcons.arrow_right_arrow_left, size: 13, color: AppColors.accent),
                  SizedBox(width: 5),
                  Text(
                    'Empareja 2 Columnas',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
            if (!_isSubmitted && _userPairings.isNotEmpty)
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                onPressed: _resetPairings,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(CupertinoIcons.arrow_counterclockwise, size: 12, color: AppColors.textMuted),
                    SizedBox(width: 4),
                    Text(
                      'Reiniciar parejas',
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
        const SizedBox(height: 10),

        // Cabeceras de Columna A y Columna B
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'COLUMNA A (Estructura)',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMuted,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'COLUMNA B (Elemento)',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMuted,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Filas interactivas con las dos columnas
        ...List.generate(_leftItems.length, (index) {
          return _buildMatchingRow(index);
        }),

        // Solución explícita en caso de fallo después de comprobar
        if (_isSubmitted) ...[
          const SizedBox(height: 10),
          _buildSolutionsSummary(),
        ],

        // Botón para comprobar relaciones
        if (!_isSubmitted) ...[
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: CupertinoButton(
              color: isAllPaired ? AppColors.accent : const Color(0xFFE5E5EA),
              borderRadius: BorderRadius.circular(14),
              onPressed: isAllPaired ? _checkAnswers : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isAllPaired ? CupertinoIcons.checkmark_alt_circle_fill : CupertinoIcons.link,
                    size: 18,
                    color: isAllPaired ? Colors.white : AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isAllPaired
                        ? 'Comprobar Relaciones'
                        : 'Conecta todas las parejas (${_userPairings.length}/${_leftItems.length})',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isAllPaired ? Colors.white : AppColors.textMuted,
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

  Widget _buildMatchingRow(int index) {
    final leftText = _leftItems[index];
    final isLeftSelected = _selectedLeftIndex == index;
    final isLeftPaired = _userPairings.containsKey(index);
    final leftPairNum = _getPairNumberForLeft(index);
    final pairColor = leftPairNum != null ? _getPairColor(leftPairNum - 1) : AppColors.accent;

    // Elemento correspondiente de la columna derecha
    final rightIndex = index < _rightItems.length ? index : null;
    final rightText = rightIndex != null ? _rightItems[rightIndex] : null;
    final isRightPaired = rightIndex != null && _getLeftIndexForRight(rightIndex) != null;
    final rightPairNum = rightIndex != null ? _getPairNumberForRight(rightIndex) : null;
    final rightPairColor = rightPairNum != null ? _getPairColor(rightPairNum - 1) : AppColors.accent;

    // Estados post-comprobación
    final isSubmitted = _isSubmitted;
    final bool isLeftCorrect = isSubmitted && isLeftPaired && _isPairCorrect(index);
    final bool isLeftIncorrect = isSubmitted && isLeftPaired && !_isPairCorrect(index);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TARJETA COLUMNA IZQUIERDA
            Expanded(
              child: _buildLeftCard(
                index: index,
                text: leftText,
                isSelected: isLeftSelected,
                isPaired: isLeftPaired,
                pairNumber: leftPairNum,
                pairColor: pairColor,
                isCorrect: isLeftCorrect,
                isIncorrect: isLeftIncorrect,
              ),
            ),
            const SizedBox(width: 10),

            // TARJETA COLUMNA DERECHA
            if (rightText != null && rightIndex != null)
              Expanded(
                child: _buildRightCard(
                  rightIndex: rightIndex,
                  text: rightText,
                  isPaired: isRightPaired,
                  pairNumber: rightPairNum,
                  pairColor: rightPairColor,
                  isTargetOfSelected: isLeftSelected,
                  isSubmitted: isSubmitted,
                  isCorrect: isSubmitted && isRightPaired && _isPairCorrect(_getLeftIndexForRight(rightIndex)!),
                  isIncorrect: isSubmitted && isRightPaired && !_isPairCorrect(_getLeftIndexForRight(rightIndex)!),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftCard({
    required int index,
    required String text,
    required bool isSelected,
    required bool isPaired,
    required int? pairNumber,
    required Color pairColor,
    required bool isCorrect,
    required bool isIncorrect,
  }) {
    Color bg = AppColors.surface;
    Color borderColor = AppColors.border;
    double borderWidth = 1.0;

    if (isCorrect) {
      bg = const Color(0xFFF0FDF4);
      borderColor = AppColors.systemGreen;
      borderWidth = 1.6;
    } else if (isIncorrect) {
      bg = const Color(0xFFFEF2F2);
      borderColor = AppColors.systemRed;
      borderWidth = 1.6;
    } else if (isSelected) {
      bg = AppColors.accent.withValues(alpha: 0.08);
      borderColor = AppColors.accent;
      borderWidth = 2.0;
    } else if (isPaired) {
      bg = pairColor.withValues(alpha: 0.05);
      borderColor = pairColor;
      borderWidth = 1.5;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _onLeftItemTapped(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Badge de orden e indicador de par
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isPaired ? pairColor : const Color(0xFFE5E5EA),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isPaired ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),
                  if (isCorrect)
                    const Icon(CupertinoIcons.checkmark_circle_fill, color: AppColors.systemGreen, size: 18)
                  else if (isIncorrect)
                    const Icon(CupertinoIcons.xmark_circle_fill, color: AppColors.systemRed, size: 18)
                  else if (isPaired)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: pairColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Par $pairNumber',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: pairColor,
                        ),
                      ),
                    )
                  else if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Toca pareja',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Texto del ítem
              Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightCard({
    required int rightIndex,
    required String text,
    required bool isPaired,
    required int? pairNumber,
    required Color pairColor,
    required bool isTargetOfSelected,
    required bool isSubmitted,
    required bool isCorrect,
    required bool isIncorrect,
  }) {
    Color bg = AppColors.surface;
    Color borderColor = AppColors.border;
    double borderWidth = 1.0;

    if (isCorrect) {
      bg = const Color(0xFFF0FDF4);
      borderColor = AppColors.systemGreen;
      borderWidth = 1.6;
    } else if (isIncorrect) {
      bg = const Color(0xFFFEF2F2);
      borderColor = AppColors.systemRed;
      borderWidth = 1.6;
    } else if (isPaired) {
      bg = pairColor.withValues(alpha: 0.05);
      borderColor = pairColor;
      borderWidth = 1.5;
    } else if (isTargetOfSelected) {
      // Estado de sugerencia cuando la izquierda está seleccionada
      bg = const Color(0xFFF8FAFC);
      borderColor = AppColors.accent.withValues(alpha: 0.4);
      borderWidth = 1.2;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _onRightItemTapped(rightIndex),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Badge de par o indicador
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isCorrect)
                    const Icon(CupertinoIcons.checkmark_circle_fill, color: AppColors.systemGreen, size: 18)
                  else if (isIncorrect)
                    const Icon(CupertinoIcons.xmark_circle_fill, color: AppColors.systemRed, size: 18)
                  else if (isPaired)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: pairColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Par $pairNumber',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: pairColor,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 18),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: isPaired ? pairColor : Colors.transparent,
                      border: Border.all(
                        color: isPaired ? pairColor : AppColors.border,
                        width: 1.5,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Texto del ítem derecho
              Text(
                text,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSolutionsSummary() {
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
            children: const [
              Icon(CupertinoIcons.checkmark_shield_fill, size: 16, color: AppColors.accent),
              SizedBox(width: 6),
              Text(
                'Relaciones Correctas del Rouvière',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(_leftItems.length, (i) {
            final left = _leftItems[i];
            final correctRight = _getCorrectRightTextForLeft(i);
            final userRightIdx = _userPairings[i];
            final isCorrect = userRightIdx != null && _rightItems[userRightIdx] == correctRight;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isCorrect ? CupertinoIcons.check_mark : CupertinoIcons.xmark,
                    size: 13,
                    color: isCorrect ? AppColors.systemGreen : AppColors.systemRed,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12, color: AppColors.primary, height: 1.3),
                        children: [
                          TextSpan(
                            text: '$left: ',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text: correctRight,
                            style: TextStyle(
                              color: isCorrect ? AppColors.systemGreen : const Color(0xFF1E293B),
                              fontWeight: isCorrect ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
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
