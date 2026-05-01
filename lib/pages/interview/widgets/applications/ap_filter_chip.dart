// ===================== File: ap_filter_chip.dart =====================
// Purpose:
// Single filter chip (All, Accepted, Pending, Rejected)
//
// Features:
// - Selected / unselected state
// - Icon support
// ===================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../constants/constants.dart';

class ApFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ApFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor(label);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIcon(label),
              size: 14,
              color: isSelected ? color : AppColors.textMuted,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= ICON =================
  IconData _getIcon(String label) {
    switch (label.toLowerCase()) {
      case "accepted":
        return PhosphorIcons.checkCircle();
      case "pending":
        return PhosphorIcons.clock();
      case "rejected":
        return PhosphorIcons.xCircle();
      default:
        return PhosphorIcons.list();
    }
  }

  // ================= COLOR =================
  Color _getColor(String label) {
    switch (label.toLowerCase()) {
      case "accepted":
        return AppColors.success;
      case "pending":
        return AppColors.warning;
      case "rejected":
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }
}
