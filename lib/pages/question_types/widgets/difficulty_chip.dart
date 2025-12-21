import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../constants/constants.dart';
import '../../../models/question.dart';

class DifficultyChip extends StatelessWidget {
  final Difficulty difficulty;

  const DifficultyChip({
    super.key,
    required this.difficulty,
  });

  Color get _color {
    switch (difficulty) {
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

  /// 🔑 UI-friendly label
  String get _label {
    switch (difficulty) {
      case Difficulty.easy_medium:
        return 'EASY-MEDIUM';
      case Difficulty.medium_hard:
        return 'MEDIUM-HARD';
      default:
        return difficulty.name.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: _color.withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhosphorIcon(
            PhosphorIcons.trendUp(PhosphorIconsStyle.regular),
            size: 14,
            color: _color,
          ),
          const SizedBox(width: 6),
          Text(
            _label,
            style: AppTextStyles.chip.copyWith(
              color: _color,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
