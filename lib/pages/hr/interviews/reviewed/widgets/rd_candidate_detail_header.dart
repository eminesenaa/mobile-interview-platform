import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '/../../../../constants/constants.dart';

class RdCandidateDetailHeader extends StatelessWidget {
  final String name;
  final String initials;
  final String subtitle;
  final String decision;
  final int rank;

  const RdCandidateDetailHeader({
    super.key,
    required this.name,
    required this.initials,
    required this.subtitle,
    required this.decision,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final isAccepted = decision == "accepted";

    return Column(
      children: [
        /// Avatar
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primarySoftBackground,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: AppShadows.low,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: AppTextStyles.headline.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        /// Name
        Text(
          name,
          style: AppTextStyles.title,
        ),

        const SizedBox(height: 4),

        /// Subtitle
        Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        /// Chips
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Decision chip
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isAccepted
                    ? AppColors.success.withOpacity(0.12)
                    : AppColors.error.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                isAccepted ? "Accepted" : "Rejected",
                style: AppTextStyles.bodySmall.copyWith(
                  color: isAccepted ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            /// Rank chip
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                "Rank #$rank",
                style: AppTextStyles.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
