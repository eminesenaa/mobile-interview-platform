import 'package:flutter/material.dart';

import '../../../../constants/constants.dart';

class AnswerSummaryRow extends StatelessWidget {
  final int correct;
  final int wrong;
  final int unanswered;

  const AnswerSummaryRow({
    super.key,
    required this.correct,
    required this.wrong,
    required this.unanswered,
  });

  Widget _buildBox({
    required String label,
    required int value,
    required Color color,
    required Color background,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: color.withOpacity(0.6),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔢 VALUE
            Text(
              '$value',
              style: AppTextStyles.headline.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // 🏷 LABEL
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildBox(
          label: 'Correct',
          value: correct,
          color: AppColors.success,
          background: AppColors.success.withOpacity(0.08),
        ),
        const SizedBox(width: AppSpacing.sm),
        _buildBox(
          label: 'Wrong',
          value: wrong,
          color: AppColors.error,
          background: AppColors.error.withOpacity(0.08),
        ),
        const SizedBox(width: AppSpacing.sm),
        _buildBox(
          label: 'Unanswered',
          value: unanswered,
          color: AppColors.textMuted,
          background: AppColors.surfaceMuted,
        ),
      ],
    );
  }
}
