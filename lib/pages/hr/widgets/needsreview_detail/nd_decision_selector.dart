import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants/constants.dart';

/// ===============================================================
/// ND DECISION SELECTOR (UPDATED 🔥)
/// ---------------------------------------------------------------
/// FIXES:
/// - Equal height boxes (crossAxisAlignment.stretch)
/// - Icon always same (✔ for Accept, ✖ for Reject)
/// - Only color changes on selection
/// ===============================================================
class NdDecisionSelector extends StatelessWidget {
  final RxnBool decision;
  final Function(bool) onSelect;

  const NdDecisionSelector({
    super.key,
    required this.decision,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _DecisionBox(
              title: "Accept",
              subtitle: "Accept & notify",
              icon: Icons.check,
              // 🔥 SABİT ICON
              isSelected: decision.value == true,
              color: AppColors.success,
              onTap: () => onSelect(true),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _DecisionBox(
              title: "Reject",
              subtitle: "Decline & notify",
              icon: Icons.close,
              // 🔥 SABİT ICON
              isSelected: decision.value == false,
              color: AppColors.error,
              onTap: () => onSelect(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecisionBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;
  final IconData icon;

  const _DecisionBox({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 120), // 🔥 EŞİT HEIGHT FIX
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 🔥 ORTALAMA
          children: [
            /// ICON (HER ZAMAN SABİT)
            Icon(
              icon,
              color: isSelected ? color : AppColors.textMuted,
              size: 28,
            ),

            const SizedBox(height: AppSpacing.sm),

            Text(
              title,
              style: AppTextStyles.bodyStrong.copyWith(
                  color: isSelected ? color : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500),
            ),

            const SizedBox(height: AppSpacing.xs),

            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? color : AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
