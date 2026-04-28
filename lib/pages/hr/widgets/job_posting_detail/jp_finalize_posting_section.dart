// ===================== FILE: jp_finalize_posting_section.dart =====================
// Purpose:
// Final action for CLOSED postings
//
// Used when:
// - Posting is closed
// - HR wants to finalize evaluation
//
// Features:
// - Clean CTA button (no icon)
// - Validation handled outside
// - Subtle helper text
// ================================================================================

import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

class JPFinalizePostingSection extends StatelessWidget {
  final VoidCallback onFinalize;

  const JPFinalizePostingSection({
    super.key,
    required this.onFinalize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ================= CTA BUTTON =================
        GestureDetector(
          onTap: onFinalize,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.4),
              ),
            ),
            child: Center(
              child: Text(
                "Finalize Evaluation",
                style: AppTextStyles.bodyStrong.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        /// ================= HELPER TEXT =================
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Review all candidates before finalizing. You can create an interview after this step.",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}