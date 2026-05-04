// ===================== File: cip_job_posting_card.dart =====================
// Purpose:
// Displays a single READY job posting.
//
// Features:
// - Title
// - Level chip
// - Location + Work type
// - Navigation arrow
// - Stats row
//
// IMPORTANT:
// - No "Ready" chip (already filtered)
// - No "Closed" info
//
// ========================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '/../../../../constants/constants.dart';

import '/../../../../models/job_posting.dart';
import 'cip_posting_stats_row.dart';

class CipJobPostingCard extends StatelessWidget {
  final JobPosting posting;
  final int applicants;
  final int accepted;
  final int rejected;
  final VoidCallback? onTap;

  const CipJobPostingCard({
    super.key,
    required this.posting,
    required this.applicants,
    required this.accepted,
    required this.rejected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER ROW =================
            Row(
              children: [
                Expanded(
                  child: Text(
                    posting.title,
                    style: AppTextStyles.title,
                  ),
                ),
                Icon(
                  PhosphorIcons.caretRight(),
                  size: AppIconSizes.md,
                  color: AppColors.textMuted,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // ================= INFO ROW =================
            Row(
              children: [
                _buildLevelChip(_formatLevel(posting.level.name)),
                const SizedBox(width: AppSpacing.sm),
                _infoItem(
                  icon: PhosphorIcons.mapPin(),
                  text: "${posting.city}, ${posting.country}",
                ),
                const SizedBox(width: AppSpacing.sm),
                _infoItem(
                  icon: PhosphorIcons.globe(),
                  text: _formatWorkType(posting.workType.name),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // ================= DIVIDER =================
            Container(
              height: 1,
              color: AppColors.border,
            ),

            const SizedBox(height: AppSpacing.md),

            // ================= STATS =================
            CipPostingStatsRow(
              applicants: applicants,
              accepted: accepted,
              rejected: rejected,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelChip(String level) {
    final color = _getLevelColor(level);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12), // 🔥 soft background
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withOpacity(0.4)), // 🔥 subtle border
      ),
      child: Text(
        level, // 🔥 artık formatlanmış geliyor
        style: AppTextStyles.chip.copyWith(
          color: color, // 🔥 dynamic color
        ),
      ),
    );
  }

  Widget _infoItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, size: AppIconSizes.sm, color: AppColors.textMuted),
        const SizedBox(width: AppSpacing.xs),
        Text(
          text,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  // =========================================================
  // 🎨 LEVEL COLOR SYSTEM
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
  String _formatLevel(String level) {
    switch (level.toLowerCase()) {
      case "intern":
        return "INTERN";
      case "junior":
        return "JUNIOR";
      case "mid":
      case "mid-level":
        return "MID-LEVEL";
      case "senior":
        return "SENIOR";
      default:
        return level.toUpperCase();
    }
  }

  String _formatWorkType(String type) {
    switch (type.toLowerCase()) {
      case "remote":
        return "Remote";
      case "hybrid":
        return "Hybrid";
      case "onsite":
        return "Onsite";
      default:
        return type;
    }
  }


}
