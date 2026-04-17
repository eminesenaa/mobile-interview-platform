// ===================== File: hr_dashboard_stats_row.dart =====================
// Purpose:
// Displays top statistics in HR Dashboard (UPDATED)
//
// Changes:
// - Label moved to top
// - Uppercase + letter spacing added
// - Value styled with primary color
// - Better visual hierarchy (matches design)
// ============================================================================

import 'package:flutter/material.dart';
import '../../../constants/constants.dart';

class HRDashboardStatsRow extends StatelessWidget {
  final int interviewCount;
  final int candidateCount;

  const HRDashboardStatsRow({
    super.key,
    required this.interviewCount,
    required this.candidateCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: interviewCount.toString(),
            label: "INTERVIEWS",
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            value: candidateCount.toString(),
            label: "CANDIDATES",
          ),
        ),
      ],
    );
  }
}

/// ===============================
/// SINGLE STAT CARD
/// ===============================
class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.low,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===============================
          // LABEL (TOP - MUTED)
          // ===============================
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // ===============================
          // VALUE (BOTTOM - STRONG)
          // ===============================
          Text(
            value,
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 22,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
