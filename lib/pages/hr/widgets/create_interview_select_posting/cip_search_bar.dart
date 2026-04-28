// ===================== File: cip_search_bar.dart =====================
// Purpose:
// Search bar for filtering job postings.
//
// Features:
// - Rounded input
// - Search icon (Phosphor)
// - Clean minimal style
//
// TODO (Controller):
// - Bind to GetX search query
// ====================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../constants/constants.dart';

class CipSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onChanged;

  const CipSearchBar({
    super.key,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.magnifyingGlass(),
            size: AppIconSizes.md,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: "Search job postings...",
                hintStyle: AppTextStyles.bodySmall,
                border: InputBorder.none,
              ),
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }
}
