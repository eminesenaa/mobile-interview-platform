// ===================== File: hr_action_card.dart =====================
// Purpose:
// Reusable action card used in HR Dashboard (UPDATED)
//
// Features:
// - Compact height
// - Left accent color bar
// - Dynamic icon color (not always primary)
// - Phosphor icons support
//
// Design Notes:
// - Uses AppSpacing, AppRadius, AppColors
// - Clean, modern card UI
// =====================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../constants/constants.dart';

class HRActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const HRActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.md,
        ),

        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.low,
        ),

        child: Row(
          children: [
            // ===============================
            // LEFT ACCENT BAR
            // ===============================
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // ===============================
            // ICON
            // ===============================
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Icon(
                icon,
                size: AppIconSizes.md,
                color: accentColor,
              ),
            ),

            const SizedBox(width: AppSpacing.lg),

            // ===============================
            // TEXT SECTION
            // ===============================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.title,
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // ===============================
            // RIGHT ARROW
            // ===============================
            Icon(
              PhosphorIcons.caretRight(),
              size: AppIconSizes.sm,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}