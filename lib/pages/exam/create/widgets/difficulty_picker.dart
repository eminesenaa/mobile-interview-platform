import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/models/question.dart';

import '../../../../constants/constants.dart';

class DifficultyPicker extends StatelessWidget {
  final RxSet<Difficulty> selected; // controller.difficulties

  const DifficultyPicker({
    super.key,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: Difficulty.values.map((d) {
          final isSelected = selected.contains(d);
          final color = _difficultyColor(d);

          return FilterChip(
            label: Text(
              _label(d),
              style: AppTextStyles.bodyStrong.copyWith(
                color: isSelected ? color : AppColors.textPrimary,
              ),
            ),
            selected: isSelected,
            onSelected: (_) {
              isSelected ? selected.remove(d) : selected.add(d);
            },

            // ✅ SELECTED STATE
            selectedColor: color.withOpacity(0.18),
            checkmarkColor: color,

            // ✅ BORDER
            side: BorderSide(
              color: color.withOpacity(0.35),
            ),

            // ✅ SHAPE
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          );
        }).toList(),
      ),
    );
  }
}

String _label(Difficulty d) {
  switch (d) {
    case Difficulty.easy:
      return 'EASY';
    case Difficulty.easy_medium:
      return 'EASY - MEDIUM';
    case Difficulty.medium:
      return 'MEDIUM';
    case Difficulty.medium_hard:
      return 'MEDIUM - HARD';
    case Difficulty.hard:
      return 'HARD';
  }
}

Color _difficultyColor(Difficulty d) {
  switch (d) {
    case Difficulty.easy:
      return AppColors.difficultyEasy;
    case Difficulty.easy_medium:
      return AppColors.difficultyEasyMedium;
    case Difficulty.medium:
      return AppColors.difficultyMedium;
    case Difficulty.medium_hard:
      return AppColors.difficultyMediumHard;
    case Difficulty.hard:
      return AppColors.difficultyHard;
  }
}
