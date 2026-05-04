// ===================== File: ap_skill_chip.dart =====================
// Purpose:
// Single removable skill chip
//
// Design:
// - Soft gray background
// - Subtle border
// - Small close icon (muted)
// ====================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../../constants/constants.dart';

class ApSkillChip extends StatelessWidget {
  final String skill;
  final VoidCallback onRemove;

  const ApSkillChip({
    super.key,
    required this.skill,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ================= TEXT =================
          Text(
            skill,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(width: AppSpacing.xs),

          // ================= REMOVE ICON =================
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              PhosphorIcons.x(),
              size: 14,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
