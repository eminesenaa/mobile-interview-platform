// ===================== File: ci_text_field.dart =====================
// Purpose:
// Custom styled input field for Create Interview
//
// Design System:
// - Label on top (uppercase, muted)
// - Rounded input box
// - No default underline
// - Consistent spacing
// ===================================================================

import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

class CITextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const CITextField({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===============================
        // LABEL (TOP)
        // ===============================
        Text(
          label.toUpperCase(),
          style: AppTextStyles.label.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: AppSpacing.xs),

        // ===============================
        // INPUT BOX
        // ===============================
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: controller,
            style: AppTextStyles.bodyStrong,

            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none, // ❗ underline kaldırıldı
              hintText: "",
            ),
          ),
        ),
      ],
    );
  }
}