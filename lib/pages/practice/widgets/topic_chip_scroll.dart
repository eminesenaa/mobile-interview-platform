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
    if (topics.isEmpty) {
      return const SizedBox.shrink();
    }

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

          return ChoiceChip(
            selected: isSelected,
            showCheckmark: false,
            avatar: isSelected
                ? const Icon(
                    Icons.check,
                    size: 16,
                    color: AppColors.textLightPrimary,
                  )
                : null,
            label: Text(
              topic,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.textLightPrimary
                    : AppColors.textSecondary,
              ),
            ),
            onSelected: (_) => onTopicSelected(topic),
            backgroundColor: AppColors.surfaceMuted,
            selectedColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 0,
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
      ),
    );
  }
}
