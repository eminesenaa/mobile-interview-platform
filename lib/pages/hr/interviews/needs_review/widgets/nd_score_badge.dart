import 'package:flutter/material.dart';
import '/../../../../constants/constants.dart';

/// ===============================================================
/// ND SCORE BADGE
/// ===============================================================
class NdScoreBadge extends StatelessWidget {
  final int score;

  const NdScoreBadge({
    super.key,
    required this.score,
  });

  Color _getColor() {
    if (score >= 90) return AppColors.difficultyEasy;
    if (score >= 70) return AppColors.difficultyEasyMedium;
    if (score >= 50) return AppColors.difficultyMedium;
    if (score >= 30) return AppColors.difficultyMediumHard;
    return AppColors.difficultyHard;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$score",
              style: AppTextStyles.bodyStrong.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            Text(
              "/100",
              style: AppTextStyles.bodySmall.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
