import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '/../../../../constants/constants.dart';

class RdCandidatesFilterBar extends StatelessWidget {
  final String selected;
  final int total;
  final int accepted;
  final int rejected;
  final Function(String) onChanged;

  const RdCandidatesFilterBar({
    super.key,
    required this.selected,
    required this.total,
    required this.accepted,
    required this.rejected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _FilterChip(
            label: "All ($total)",
            selected: selected == "all",
            onTap: () => onChanged("all"),
            icon: PhosphorIcons.listBullets(PhosphorIconsStyle.bold),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(
            label: "Accepted ($accepted)",
            selected: selected == "accepted",
            onTap: () => onChanged("accepted"),
            color: AppColors.success,
            icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(
            label: "Rejected ($rejected)",
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
        duration: const Duration(milliseconds: 180), // 🔥 smooth anim
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color:
              selected ? baseColor.withOpacity(0.12) : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(10), // 🔥 daha kare
          border: Border.all(
            color: selected ? baseColor : AppColors.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 🔥 ICON
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
