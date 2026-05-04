// ===================== File: id_section_header.dart =====================
// Purpose:
// Reusable section header with title + optional action (e.g. "View all")
//
// Usage:
// OPEN POSITIONS / MY APPLICATIONS / RESULTS
// =======================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../constants/constants.dart';

class IdSectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onTap;

  const IdSectionHeader({
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
        Text(
          title.toUpperCase(),
          style: AppTextStyles.label.copyWith(
            fontSize: 13
          ),
        ),
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
