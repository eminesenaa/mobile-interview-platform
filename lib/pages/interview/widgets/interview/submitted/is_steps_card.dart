// ===================== File: is_steps_card.dart =====================
// Purpose:
// Displays "What happens next?" section with steps
//
// Enhancements:
// - Divider between items (premium look)
// - Bold highlighted keywords using RichText
// ===================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../../constants/constants.dart';
import 'is_step_item.dart';

class IsStepsCard extends StatelessWidget {
  const IsStepsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= HEADER =================
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Icon(
                  PhosphorIcons.article(),
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  "WHAT HAPPENS NEXT?",
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          // ================= DIVIDER =================
          const Divider(
            height: 1,
            color: AppColors.border,
          ),

          // ================= STEP 1 =================
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: IsStepItem(
              index: 1,
              richText: TextSpan(
                children: [
                  TextSpan(
                    text: "HR will review your interview ",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextSpan(
                    text: "responses",
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text:
                    " and evaluate your performance across all topics.",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(
            height: 1,
            color: AppColors.border,
          ),

          // ================= STEP 2 =================
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: IsStepItem(
              index: 2,
              richText: TextSpan(
                children: [
                  TextSpan(
                    text: "Results will be available in the ",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextSpan(
                    text: "Interview Results",
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: " section of your dashboard.",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(
            height: 1,
            color: AppColors.border,
          ),

          // ================= STEP 3 =================
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: IsStepItem(
              index: 3,
              richText: TextSpan(
                children: [
                  TextSpan(
                    text: "You may receive ",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextSpan(
                    text: "additional feedback",
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: " or a follow-up from the hiring team.",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}