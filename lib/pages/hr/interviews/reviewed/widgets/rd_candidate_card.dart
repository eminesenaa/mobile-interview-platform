import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:interview_project/constants/constants.dart';

class RdCandidateCard extends StatelessWidget {
  final int rank;
  final String name;
  final String initials;
  final int score;
  final String decision;
  final VoidCallback onTap;

  const RdCandidateCard({
    super.key,
    required this.rank,
    required this.name,
    required this.initials,
    required this.score,
    required this.decision,
    required this.onTap,
  });

  Widget _buildScoreBadge(int score) {
    Color color;
    if (score >= 90) {
      color = AppColors.success;
    } else if (score >= 50) {
      color = AppColors.warning;
    } else {
      color = AppColors.error;
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$score",
            style: AppTextStyles.bodyStrong.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          Text(
            "/100",
            style: AppTextStyles.bodySmall.copyWith(
              color: color.withOpacity(0.8),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAccepted = decision == "accepted";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.low,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// ================= LEFT SIDE =================
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center, // 🔥 ortalı
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
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
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

                      /// Crown
                      if (rank == 1)
                        Positioned(
                          top: -12,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Icon(
                              PhosphorIcons.crownSimple(PhosphorIconsStyle.fill),
                              size: 16,
                              color: AppColors.rankGold,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(width: AppSpacing.md),

                  /// Name & Decision (under name)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          style: AppTextStyles.title,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isAccepted ? "Accepted" : "Rejected",
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isAccepted ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.w600,
                            fontSize: 11, // 🔥 Küçültüldü
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// ================= RIGHT SIDE =================
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// 🔥 Score (primary)
                _buildScoreBadge(score),
              ],
            ),

            const SizedBox(width: AppSpacing.sm),

            /// 🔥 Arrow (top align hissi verir)
            Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
