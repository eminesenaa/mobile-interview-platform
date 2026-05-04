// ===================== File: status_badge.dart =====================
// Purpose:
// Reusable status badge for all interview-related UI
//
// Usage:
// StatusBadge.from(status: "ongoing", reviewStatus: "pending")
//
// ==================================================================

import 'package:flutter/material.dart';

import '../../../../constants/colors.dart';
import '../../../../constants/constants.dart';

//
// ===============================
// STATUS MODEL
// ===============================
class StatusConfig {
  final String label;
  final Color color;

  const StatusConfig({
    required this.label,
    required this.color,
  });
}

//
// ===============================
// STATUS MAPPER (LOGIC)
// ===============================
class StatusMapper {
  static StatusConfig map({
    required String status,
    required String reviewStatus,
  }) {
    // ONGOING
    if (status == "ongoing") {
      return const StatusConfig(
        label: "Ongoing",
        color: AppColors.strawberryRed,
      );
    }

    // UPCOMING
    if (status == "upcoming") {
      return const StatusConfig(
        label: "Upcoming",
        color: AppColors.topicTurquoise,
      );
    }

    // NEEDS REVIEW
    if (status == "completed" && reviewStatus == "pending") {
      return const StatusConfig(
        label: "Needs Review",
        color: AppColors.honeyBronze,
      );
    }

    // REVIEWED
    if (status == "completed" && reviewStatus == "reviewed") {
      return const StatusConfig(
        label: "Reviewed",
        color: AppColors.accentCeladon,
      );
    }

    return const StatusConfig(
      label: "Unknown",
      color: AppColors.textMuted,
    );
  }
}

//
// ===============================
// STATUS BADGE (UI)
// ===============================
class StatusBadge extends StatelessWidget {
  final StatusConfig config;

  const StatusBadge({
    super.key,
    required this.config,
  });

  /// Shortcut constructor (çok önemli 🔥)
  factory StatusBadge.from({
    required String status,
    required String reviewStatus,
  }) {
    final config = StatusMapper.map(
      status: status,
      reviewStatus: reviewStatus,
    );

    return StatusBadge(config: config);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        config.label,
        style: AppTextStyles.bodySmall.copyWith(
          color: config.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
