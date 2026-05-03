// ===================== File: ir_pending_section.dart =====================
// Purpose:
// Shows "Under Review" UI (Premium version)
//
// Upgrades:
// - Centered layout
// - Strong typography hierarchy
// - Multi-line description
// - Status chip (premium)
// =====================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../../constants/constants.dart';

class IrPendingSection extends StatelessWidget {
  const IrPendingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // =====================================================
        // ICON (CLEAN - NO CONTAINER)
        // =====================================================
        Icon(
          PhosphorIcons.clock(),
          size: 44,
          color: AppColors.warning,
        ),

        const SizedBox(height: AppSpacing.lg),

        // =====================================================
        // TITLE
        // =====================================================
        Text(
          "Under Review",
          style: AppTextStyles.headline.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // =====================================================
        // DESCRIPTION (🔥 UPDATED)
        // =====================================================
        Text(
          "Your interview is currently being reviewed by the HR team. "
          "You will be notified once the evaluation is complete.",
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // =====================================================
        // STATUS CHIP
        // =====================================================
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: AppColors.warning.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // small dot
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),

              Text(
                "Evaluation in progress",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
