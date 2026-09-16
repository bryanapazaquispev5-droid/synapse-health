import 'package:flutter/material.dart';
import '../../model/captcha_models.dart';

class CaptchaTileWidget extends StatelessWidget {
  final CaptchaTile tile;
  final bool isSelected;
  final VoidCallback onTap;

  const CaptchaTileWidget({
    super.key,
    required this.tile,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A73E8) : const Color(0xFFE2E8F0),
            width: isSelected ? 3.5 : 1.0,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Image.network(
                tile.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFF1F5F9),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(tile.fallbackIcon, size: 28, color: const Color(0xFF64748B)),
                      const SizedBox(height: 3),
                      Text(
                        tile.label,
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isSelected) ...[
              Container(
                decoration: BoxDecoration(color: const Color(0xFF1A73E8).withValues(alpha: 0.22)),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A73E8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 14, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
