import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '/../../../../constants/constants.dart';

/// ===================== APPLICANTS FILTER BAR =====================
/// Redesigned:
/// - Horizontal scroll (no wrap overflow)
/// - Icon + label style
/// - Animated selection
/// - Matches premium UI
/// ================================================================

class JPApplicantsFilterBar extends StatelessWidget {
  final String selected;
  final Function(String) onChanged;

  final int allCount;
  final int acceptedCount;
  final int rejectedCount;
  final int pendingCount;

  const JPApplicantsFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.allCount,
    required this.acceptedCount,
    required this.rejectedCount,
    required this.pendingCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _FilterChip(
            label: "All ($allCount)",
            selected: selected == "all",
            onTap: () => onChanged("all"),
            icon: PhosphorIcons.listBullets(PhosphorIconsStyle.bold),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(
            label: "Pending ($pendingCount)",
            selected: selected == "pending",
            onTap: () => onChanged("pending"),
            color: AppColors.warning,
            icon: PhosphorIcons.hourglass(PhosphorIconsStyle.fill),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(
            label: "Accepted ($acceptedCount)",
            selected: selected == "accepted",
            onTap: () => onChanged("accepted"),
            color: AppColors.success,
            icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(
            label: "Rejected ($rejectedCount)",
            selected: selected == "rejected",
            onTap: () => onChanged("rejected"),
            color: AppColors.error,
            icon: PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
          ),
        ],
      ),
    );
  }
}

/// ===================== FILTER CHIP =====================
/// Internal reusable chip
/// ======================================================

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;
  final IconData icon;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color:
              selected ? baseColor.withOpacity(0.12) : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? baseColor : AppColors.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// ICON
            Icon(
              icon,
              size: 16,
              color: selected ? baseColor : AppColors.textMuted,
            ),

            const SizedBox(width: 6),

            /// TEXT
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: selected ? baseColor : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
