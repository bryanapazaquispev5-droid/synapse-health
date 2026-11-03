// ============================================================================
// File: medical_area_card.dart
// Purpose: Atomic visual component [medical_area_card] for structured medical content and summaries.
// ============================================================================

import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';
import '../../model/medical_area_model.dart';
import '../area_topics_screen.dart';

// Modular visual component [MedicalAreaCard]
class MedicalAreaCard extends StatelessWidget {
  final MedicalAreaModel area;

  const MedicalAreaCard({super.key, required this.area});

  // Reactive rendering of the widget tree
  // Block: Reactive rendering of the main widget tree
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey(area.id),
      onTap: () {
        // Block: Navigate smoothly to the next screen
        Navigator.push(
          context,
          AppPageRoute(
            child: AreaTopicsScreen(area: area),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.6),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: area.hasImage
                        ? area.buildLogoWidget(size: 26)
                        : const Icon(CupertinoIcons.book_fill, size: 22, color: AppColors.accent),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#${area.order}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  area.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      area.topicsCount > 0
                          ? '${area.topicsCount} ${area.topicsCount == 1 ? "topic" : "topics"}'
                          : 'Available',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: area.topicsCount > 0 ? AppColors.accent : AppColors.textMuted,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      CupertinoIcons.chevron_forward,
                      size: 13,
                      color: Color(0xFFC7C7CC),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
