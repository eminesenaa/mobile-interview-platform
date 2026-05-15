import 'package:flutter/material.dart';
import '/../../../../constants/constants.dart';
import 'nd_score_badge.dart';

/// ===============================================================
/// ND CANDIDATE CARD (FINAL VERSION)
/// ---------------------------------------------------------------
/// - Rank plain text
/// - Progress bar yok
/// - Clean layout
/// - Topic chips destekli
/// ===============================================================
class NdCandidateCard extends StatelessWidget {
  final int rank;
  final String name;
  final String initials;
  final int score;
  final String? decision; // 🔥 Added decision
  final Map<String, int>? topics;
  final VoidCallback onReview;

  const NdCandidateCard({
    super.key,
    required this.rank,
    required this.name,
    required this.initials,
    required this.score,
    this.decision,
    this.topics,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: decision == "accepted"
              ? AppColors.success.withOpacity(0.5)
              : decision == "rejected"
                  ? AppColors.error.withOpacity(0.5)
                  : AppColors.border,
          width: decision != null ? 1.5 : 1.0,
        ),
        boxShadow: AppShadows.low,
      ),

      /// 🔥 Column yaptık (chips için)
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// =========================
          /// MAIN ROW
          /// =========================
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// LEFT SIDE
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// Rank
                    Text(
                      "$rank",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(width: AppSpacing.sm),

                    /// Avatar
                    _Avatar(initials: initials),

                    const SizedBox(width: AppSpacing.sm),

                    /// Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: AppTextStyles.title,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (decision != null)
                            Text(
                              decision == "accepted" ? "Accepted" : "Rejected",
                              style: AppTextStyles.bodySmall.copyWith(
                                color: decision == "accepted"
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              /// RIGHT SIDE
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  NdScoreBadge(score: score),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: onReview,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      decision != null ? "View Result" : "Review",
                      style: AppTextStyles.textButton.copyWith(
                        color: decision == "accepted"
                            ? AppColors.success
                            : decision == "rejected"
                                ? AppColors.error
                                : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          /// =========================
          /// TOPIC CHIPS 🔥
          /// =========================
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
    );
  }
}

/// ===============================================================
/// AVATAR
/// ===============================================================
class _Avatar extends StatelessWidget {
  final String initials;

  const _Avatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.primary,
      child: Text(
        initials,
        style: AppTextStyles.bodyStrong.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }
}

/// ===============================================================
/// TOPIC CHIP
/// ===============================================================
class _TopicChip extends StatelessWidget {
  final String label;

  const _TopicChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted, // 🔥 soft gri
        borderRadius: BorderRadius.circular(AppRadius.md), // karemsi
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
