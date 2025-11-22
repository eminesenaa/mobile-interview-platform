import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:interview_project/constants/colors.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/constants/text_styles.dart';
import '../../../models/leaderboard.dart';

class LeaderboardListItem extends StatelessWidget {
  final LeaderboardEntry e;

  const LeaderboardListItem({super.key, required this.e});

  @override
  Widget build(BuildContext context) {
    final bool isUp = e.delta > 0;
    final bool isDown = e.delta < 0;

    final Color trendColor = e.delta == 0
        ? AppColors.textMuted
        : (isUp ? AppColors.success : AppColors.error);

    // SVG ikon dosyası – LeaderboardCard'daki _MeRow ile aynı mantık
    final String trendIconAsset;
    if (e.delta > 0) {
      trendIconAsset = 'assets/images/up_icon.svg';
    } else if (e.delta < 0) {
      trendIconAsset = 'assets/images/down_icon.svg';
    } else {
      trendIconAsset = 'assets/images/unchanged_icon.svg';
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: (e.isMe ?? false)
              ? AppColors.primary.withValues(alpha: 0.45)
              : AppColors.border.withValues(alpha: 0.6),
          width: (e.isMe ?? false) ? 2.6 : 1,
        ),
        boxShadow: AppShadows.low,
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 28,
            child: Text(
              e.rank.toString().padLeft(2, '0'),
              style: AppTextStyles.bodyStrong.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryAccent.withOpacity(0.15),
            child: Text(
              e.initials,
              style: AppTextStyles.bodyStrong.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Name + XP
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyStrong.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const SizedBox(width: 4),
                    Text(
                      '${e.xp} XP',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Delta
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                e.delta == 0
                    ? '0'
                    : (e.delta > 0 ? '+${e.delta}' : '${e.delta}'),
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: trendColor,
                ),
              ),
              const SizedBox(width: 4),
              SvgPicture.asset(
                trendIconAsset,
                width: 12,
                height: 12,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
