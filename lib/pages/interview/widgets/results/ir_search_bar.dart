// ===================== File: ir_search_bar.dart =====================
// Purpose:
// Search bar for filtering interview widgets by title
// ===================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../../constants/constants.dart';

class IrSearchBar extends StatelessWidget {
  final Function(String) onChanged;

  const IrSearchBar({
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
          // 🔍 ICON
          Icon(
            PhosphorIcons.magnifyingGlass(),
            size: 18,
            color: AppColors.textMuted,
          ),

          const SizedBox(width: AppSpacing.sm),

          // 📝 INPUT
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: "Search interview widgets...",
                hintStyle: AppTextStyles.body.copyWith(
                  color: AppColors.textMuted,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
