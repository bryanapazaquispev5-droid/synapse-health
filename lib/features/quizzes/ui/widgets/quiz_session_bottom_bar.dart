import 'package:flutter/cupertino.dart';

class QuizSessionBottomBar extends StatelessWidget {
  final bool hasNext;
  final VoidCallback onNext;

  const QuizSessionBottomBar({
    super.key,
    required this.hasNext,
    required this.onNext,
  });

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
              hasNext ? 'Siguiente Pregunta' : 'Ver Resultados Finales',
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
