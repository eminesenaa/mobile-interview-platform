// ===================== File: is_title_section.dart =====================
// Purpose:
// Displays title & subtitle for submission screen
// =====================================================================

import 'package:flutter/material.dart';
import '../../../../../constants/constants.dart';

class IsTitleSection extends StatelessWidget {
  const IsTitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Interview submitted\nsuccessfully",
          textAlign: TextAlign.center,
          style: AppTextStyles.headline.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          "Your responses have been sent to the HR team\nfor evaluation. You will be notified once the\nreview is complete.",
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
