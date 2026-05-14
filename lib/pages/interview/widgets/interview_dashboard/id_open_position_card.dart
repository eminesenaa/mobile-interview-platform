// ===================== File: id_open_position_card.dart =====================
// Purpose:
// Displays a job posting for candidate (OPEN POSITION)
//
// Features:
// - Title
// - Level chip (HR ile aynı renk sistemi)
// - Location + Work type
// - Description
// - Apply button
//
// IMPORTANT:
// - Uses Map<String, dynamic> (backend-ready)
// - Same structure as HR posting (consistency)
// - Stateless (data comes from controller)
//
// ============================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../constants/constants.dart';

class IdOpenPositionCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final VoidCallback onApply;
  final bool isApplied;

  const IdOpenPositionCard({
    super.key,
    required this.job,
    required this.onApply,
    this.isApplied = false,
  });

  @override
  Widget build(BuildContext context) {
    final level = job["level"] ?? "";
    final levelColor = _getLevelColor(level);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= HEADER =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  job["title"] ?? "",
                  style: AppTextStyles.title,
                ),
              ),
              _levelChip(level, levelColor),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // ================= LOCATION =================
          Row(
            children: [
              Icon(
                PhosphorIcons.mapPin(),
                size: AppIconSizes.sm,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  job["location"] ?? "",
                  style: AppTextStyles.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                PhosphorIcons.globe(),
                size: AppIconSizes.sm,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                job["workType"] ?? "",
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // ================= DESCRIPTION =================
          Text(
            job["description"] ?? "",
            style: AppTextStyles.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppSpacing.md),

          // ================= APPLY BUTTON =================
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: isApplied ? null : onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: isApplied ? AppColors.border : AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isApplied ? "Submitted" : "Apply",
                    style: AppTextStyles.button.copyWith(
                      color: isApplied ? AppColors.textMuted : Colors.white,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    isApplied
                        ? PhosphorIcons.checkCircle(PhosphorIconsStyle.bold)
                        : PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
                    size: AppIconSizes.sm,
                    color: isApplied ? AppColors.textMuted : Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // 🎨 LEVEL CHIP (HR ile aynı sistem)
  // =========================================================
  Widget _levelChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.chip.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // =========================================================
  // 🎨 LEVEL COLOR SYSTEM (HR ile birebir)
  // =========================================================
  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case "intern":
        return AppColors.darkCyan;
      case "junior":
        return AppColors.darkMagenta;
      case "mid-level":
        return AppColors.topicTurquoise;
      case "senior":
        return AppColors.pinkCarnation;
      default:
        return AppColors.honeyBronze;
    }
  }
}
