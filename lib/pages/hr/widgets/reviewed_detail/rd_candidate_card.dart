import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

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
                  CircleAvatar(
                    radius: 20, // 🔥 biraz büyüttük
                    backgroundColor: AppColors.primary,
                    child: Text(
                      initials,
                      style: AppTextStyles.bodyStrong.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(width: AppSpacing.md),

                  /// Name
                  Expanded(
                    child: Text(
                      name,
                      style: AppTextStyles.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            /// ================= RIGHT SIDE =================
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// 🔥 Score (primary)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "$score",
                      style: AppTextStyles.bodyStrong.copyWith(
                        fontSize: 18, // 🔥 daha büyük
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "/100",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xs),

                /// 🔥 Decision chip (secondary)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isAccepted
                        ? AppColors.success.withOpacity(0.12)
                        : AppColors.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isAccepted ? "Accepted" : "Rejected",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isAccepted ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
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
