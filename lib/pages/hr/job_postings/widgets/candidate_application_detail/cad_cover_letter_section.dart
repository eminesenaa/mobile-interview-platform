// ===================== FILE: cad_cover_letter_section.dart =====================
// Displays long cover letter text
// ============================================================================

import 'package:flutter/material.dart';
import '/../../../../constants/constants.dart';

class CADCoverLetterSection extends StatelessWidget {
  final String text;

  const CADCoverLetterSection({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return _card(
      Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          height: 1.5,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
