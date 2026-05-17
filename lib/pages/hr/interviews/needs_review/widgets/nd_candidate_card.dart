import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '/../../../../constants/constants.dart';
import 'nd_score_badge.dart';

/// ===============================================================
/// ND CANDIDATE CARD
/// ---------------------------------------------------------------
/// FEATURES:
/// - Fully clickable card
/// - Compact modern layout
/// - Premium minimal avatar
/// - Crown for top ranked candidate
/// - Score badge + chevron navigation
/// - Optional topic chips
///
/// DESIGN GOAL:
/// Apple / Airbnb style clean recruiter dashboard UI
/// ===============================================================
class NdCandidateCard extends StatelessWidget {
  final int rank;
  final String name;
  final String initials;
  final int score;
  final Map<String, int>? topics;
  final VoidCallback onReview;

  const NdCandidateCard({
    super.key,
    required this.rank,
    required this.name,
    required this.initials,
    required this.score,
    this.topics,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onReview,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.border,
          ),
          boxShadow: AppShadows.low,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ===================================================
            /// MAIN CONTENT ROW
            /// ===================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// =================================================
                /// LEFT SIDE
                /// =================================================
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// Rank number
                      Text(
                        "$rank",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(width: AppSpacing.sm),

                      /// Avatar
                      _Avatar(
                        initials: initials,
                        rank: rank,
                      ),

                      const SizedBox(width: AppSpacing.sm),

                      /// Candidate name
                      Expanded(
                        child: Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.title,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),

                /// =================================================
                /// RIGHT SIDE
                /// =================================================
                Row(
                  children: [
                    /// Score badge
                    NdScoreBadge(score: score),

                    const SizedBox(width: AppSpacing.sm),

                    /// Navigation chevron
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),

            /// ===================================================
            /// TOPIC CHIPS
            /// ===================================================
            if (topics != null && topics!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: topics!.entries.map((e) {
                  return _TopicChip(
                    label: "${e.key} ${e.value}%",
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ===============================================================
/// AVATAR
/// ---------------------------------------------------------------
/// - Soft premium background
/// - Crown for #1 candidate
/// - Minimal recruiter dashboard aesthetic
/// ===============================================================
class _Avatar extends StatelessWidget {
  final String initials;
  final int rank;

  const _Avatar({
    required this.initials,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        /// =======================================================
        /// MAIN AVATAR
        /// =======================================================
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primarySoftBackground,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              initials,
              style: AppTextStyles.bodyStrong.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),

        /// =======================================================
        /// TOP CANDIDATE CROWN
        /// =======================================================
        if (rank == 1)
          Positioned(
            top: -10,
            left: 0,
            right: 0,
            child: Center(
              child: Icon(
                PhosphorIcons.crownSimple(
                  PhosphorIconsStyle.fill,
                ),
                size: 14,
                color: AppColors.honeyBronze,
              ),
            ),
          ),
      ],
    );
  }
}

/// ===============================================================
/// TOPIC CHIP
/// ---------------------------------------------------------------
/// Optional analytics/topic performance chips
/// ===============================================================
class _TopicChip extends StatelessWidget {
  final String label;

  const _TopicChip({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(
          AppRadius.md,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.chip.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
