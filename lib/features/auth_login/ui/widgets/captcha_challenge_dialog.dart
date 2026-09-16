import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../model/captcha_challenges_data.dart';
import '../../model/captcha_models.dart';
import 'captcha_tile_widget.dart';

/// Diálogo interactivo del desafío de selección de imágenes (reCAPTCHA Grid Challenge)
class CaptchaChallengeDialog extends StatefulWidget {
  const CaptchaChallengeDialog({super.key});

  @override
  State<CaptchaChallengeDialog> createState() => _CaptchaChallengeDialogState();
}

class _CaptchaChallengeDialogState extends State<CaptchaChallengeDialog> {
  late int _currentChallengeIndex;
  final Set<int> _selectedIndices = {};
  bool _hasError = false;
  String _errorMessage = '';

  final List<CaptchaChallenge> _challenges = CaptchaChallengesData.challenges;

  @override
  void initState() {
    super.initState();
    _currentChallengeIndex = Random().nextInt(_challenges.length);
  }

  void _handleNextChallenge() {
    HapticFeedback.selectionClick();
    setState(() {
      _currentChallengeIndex = (_currentChallengeIndex + 1) % _challenges.length;
      _selectedIndices.clear();
      _hasError = false;
      _errorMessage = '';
    });
  }

  void _handleToggleTile(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _hasError = false;
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _handleVerifyChallenge() {
    final challenge = _challenges[_currentChallengeIndex];
    final bool isCorrect = _selectedIndices.length == challenge.correctIndices.length &&
        _selectedIndices.containsAll(challenge.correctIndices);

    if (isCorrect) {
      Navigator.of(context).pop(true);
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _hasError = true;
        _errorMessage = 'Por favor, vuelve a intentarlo. Selecciona todas las imágenes correctas.';
        _selectedIndices.clear();
        _currentChallengeIndex = (_currentChallengeIndex + 1) % _challenges.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final challenge = _challenges[_currentChallengeIndex];

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 12,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFF1A73E8),
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecciona todas las imágenes que contengan',
                    style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    challenge.keyword,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    challenge.subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            if (_hasError)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                color: const Color(0xFFFEF2F2),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 16, color: Color(0xFFDC2626)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF991B1B)),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: challenge.tiles.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  final tile = challenge.tiles[index];
                  final bool isSelected = _selectedIndices.contains(index);
                  return CaptchaTileWidget(
                    tile: tile,
                    isSelected: isSelected,
                    onTap: () => _handleToggleTile(index),
                  );
                },
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Color(0xFF5F6368), size: 22),
                    tooltip: 'Cambiar desafío',
                    onPressed: _handleNextChallenge,
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: const Icon(Icons.headphones_rounded, color: Color(0xFF5F6368), size: 22),
                    tooltip: 'Accesibilidad de audio',
                    onPressed: () {},
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline_rounded, color: Color(0xFF5F6368), size: 22),
                    tooltip: 'Ayuda',
                    onPressed: () {},
                    visualDensity: VisualDensity.compact,
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A73E8),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    onPressed: _handleVerifyChallenge,
                    child: const Text(
                      'VERIFICAR',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
