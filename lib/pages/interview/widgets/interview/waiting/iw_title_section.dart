// ===================== File: iw_title_section.dart =====================
// Purpose:
// Displays title + subtitle
// =====================================================================

import 'package:flutter/material.dart';

import '../../../../../constants/constants.dart';


class IwTitleSection extends StatelessWidget {
  const IwTitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Your interview will\nstart shortly",
          textAlign: TextAlign.center,
          style: AppTextStyles.headline.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          "Stay on this page. You will be automatically\nredirected when the session begins.",
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
