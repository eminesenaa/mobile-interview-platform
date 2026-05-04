// ===================== File: ir_filter_chip.dart =====================
// Purpose:
// Single filter chip (All / Accepted / Pending / Rejected)
//
// Features:
// - Dynamic color based on status
// - Primary for "All"
// - Status-based colors for others
// ====================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../../constants/constants.dart';

class IrFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const IrFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  // ================= ICON =================
  IconData _getIcon() {
    switch (label.toLowerCase()) {
      case 'accepted':
        return PhosphorIcons.checkCircle(PhosphorIconsStyle.bold);
      case 'rejected':
        return PhosphorIcons.xCircle(PhosphorIconsStyle.bold);
      case 'pending':
        return PhosphorIcons.clock(PhosphorIconsStyle.bold);

      default:
        return PhosphorIcons.list(PhosphorIconsStyle.bold);
    }
  }

  // ================= COLOR =================
  Color _getColor() {
    switch (label.toLowerCase()) {
      case 'accepted':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.primary; // All
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          // ================= BACKGROUND =================
          color: isSelected ? color.withOpacity(0.1) : AppColors.surface,

          borderRadius: BorderRadius.circular(AppRadius.md),

          // ================= BORDER =================
          border: Border.all(
            color: isSelected ? color : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ================= ICON =================
            Icon(
              _getIcon(),
              size: 15,
              color: isSelected ? color : AppColors.textMuted,
            ),

            const SizedBox(width: AppSpacing.xs),

            // ================= TEXT =================
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
}
