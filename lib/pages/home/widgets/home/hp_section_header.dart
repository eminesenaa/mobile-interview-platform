// ===================== File: hp_section_header.dart =====================
// Purpose:
// Reusable section header for Home Page
//
// Features:
// - Title (left)
// - Optional action text (right)
// - Clean spacing & alignment
// ======================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '/../../../constants/constants.dart';

class HpSectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onTap;

  const HpSectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // LEFT → Section title
        Text(
          title.toUpperCase(),
          style: AppTextStyles.label.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),

        // RIGHT → Optional action (e.g. "See all")
        if (actionText != null)
          GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                Text(
                  actionText!,
                  style: AppTextStyles.textButton,
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
                  size: AppIconSizes.sm,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
