// ===================== File: section_label.dart =====================
// Purpose:
// Reusable section label with optional action (e.g. "See all")
//
// Usage:
// SectionLabel(title: "Training Modules")
// SectionLabel(title: "Training Modules", actionText: "See all", onTap: () {})
// ====================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../constants/constants.dart';

class SectionLabel extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onTap;

  const SectionLabel({
    super.key,
    required this.title,
    this.actionText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ================= TITLE =================
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.label.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        // ================= ACTION =================
        if (actionText != null && onTap != null)
          GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                Text(
                  actionText!,
                  style: AppTextStyles.textButton,
                ),
                const SizedBox(width: 4),
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
