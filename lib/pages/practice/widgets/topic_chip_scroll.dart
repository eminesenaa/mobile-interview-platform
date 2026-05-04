// ===================== File: topic_chip_scroll.dart =====================
// Purpose:
// Clean, minimal topic chips (NO icon, NO aggressive animation)
//
// Updates:
// - Removed check icon
// - Removed ChoiceChip (less animation)
// - Custom container → smoother UX
// ======================================================================

import 'package:flutter/material.dart';
import '../../../constants/constants.dart';

class TopicChipScroll extends StatelessWidget {
  final List<String> topics;
  final String selectedTopic;
  final ValueChanged<String> onTopicSelected;

  const TopicChipScroll({
    super.key,
    required this.topics,
    required this.selectedTopic,
    required this.onTopicSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        itemCount: topics.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final topic = topics[index];
          final isSelected = topic == selectedTopic;

          return GestureDetector(
            onTap: () => onTopicSelected(topic),

            // 🔥 smooth but subtle transition
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.border.withOpacity(0.6),
                ),
              ),
              child: Center(
                child: Text(
                  topic,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.textLightPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
