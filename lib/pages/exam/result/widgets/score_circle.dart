import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../constants/constants.dart';

/// Big score circle used at the top of the result page.
/// Uses percent_indicator for a clean, modern result look.
class ScoreCircle extends StatelessWidget {
  final int score;
  final int total;

  const ScoreCircle({
    super.key,
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0.0 : (score / total).clamp(0.0, 1.0);

    return CircularPercentIndicator(
      radius: 80,
      lineWidth: 10,
      percent: percent,
      animation: true,
      animateFromLastPercent: true,
      circularStrokeCap: CircularStrokeCap.round,

      // 🎨 Colors
      progressColor: AppColors.primary,
      backgroundColor: AppColors.border,

      // 🧠 Center content
      center: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$score',
            style: AppTextStyles.headline.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'out of $total',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
