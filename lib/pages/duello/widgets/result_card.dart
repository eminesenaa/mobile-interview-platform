// lib/pages/duello/widgets/result_card.dart

import 'package:flutter/material.dart';
import 'package:interview_project/constants/constants.dart';

/// ===============================================================
/// 🧩 RESULT CARD
/// ===============================================================
///
/// Reusable stat card:
/// - Score
/// - XP
/// - Accuracy
/// - Combo
///
class ResultCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;
  final Widget? trailing;

  const ResultCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(highlight ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: highlight
            ? Border.all(
          color: AppColors.textLightPrimary.withOpacity(0.4),
          width: 1.5,
        )
            : null,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.textLightPrimary,
            size: 20,
          ),

          const SizedBox(width: AppSpacing.md),

          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textLightPrimary.withOpacity(0.75),
            ),
          ),

          const Spacer(),

          trailing ??
              Text(
                value,
                style: AppTextStyles.bodyStrong.copyWith(
                  fontSize: 17,
                  color: AppColors.textLightPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
        ],
      ),
    );
  }
}