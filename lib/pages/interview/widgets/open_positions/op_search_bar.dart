// ===================== File: op_search_bar.dart =====================
// Purpose:
// Search input for filtering job postings by title
//
// Features:
// - Phosphor search icon
// - Rounded container
// - Calls controller on text change
// ===================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../constants/constants.dart';

class OpSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const OpSearchBar({
    super.key,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: "Search job titles...",
                hintStyle: AppTextStyles.bodySmall,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
