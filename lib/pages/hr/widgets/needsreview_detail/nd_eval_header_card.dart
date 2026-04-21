import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

/// ===============================================================
/// ND EVALUATION HEADER CARD
/// ---------------------------------------------------------------
/// - Candidate info
/// - Interview info
/// - Rank
/// - Big score badge (right side)
/// ===============================================================
class NdEvalHeaderCard extends StatelessWidget {
  final String name;
  final String interviewTitle;
  final String interviewDate;
  final int rank;
  final int score;

  const NdEvalHeaderCard({
    super.key,
    required this.name,
    required this.interviewTitle,
    required this.interviewDate,
    required this.rank,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.low,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ================= LEFT SIDE =================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Evaluating label
                Text(
                  "EVALUATING",
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: AppSpacing.xs),

                /// Candidate name
                Text(
                  name,
                  style: AppTextStyles.title.copyWith(
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: AppSpacing.xs),

                /// Interview info
                Text(
                  "$interviewTitle • $interviewDate",
                  style: AppTextStyles.bodySmall,
                ),

                const SizedBox(height: AppSpacing.sm),

                /// Rank chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    "Rank #$rank",
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          /// ================= RIGHT SIDE =================
          _ScoreBox(score: score),
        ],
      ),
    );
  }
}

/// ===============================================================
/// SCORE BOX (RIGHT SIDE)
/// ===============================================================
class _ScoreBox extends StatelessWidget {
  final int score;

  const _ScoreBox({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.primarySoftBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$score",
              style: AppTextStyles.bodyStrong.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            Text(
              "/100",
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
