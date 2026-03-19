import 'package:flutter/material.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/models/duel_player.dart';
import 'package:interview_project/pages/duello/widgets/player_mini_avatar.dart';

class LeaderboardItem extends StatelessWidget {
  final DuelPlayer player;
  final int rank;
  final bool isMe;

  const LeaderboardItem({
    super.key,
    required this.player,
    required this.rank,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(isMe ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: isMe
            ? Border.all(
                color: AppColors.textLightPrimary.withOpacity(0.4),
                width: 1.5,
              )
            : null,
      ),
      child: Row(
        children: [
          /// RANK
          Text(
            '$rank.',
            style: AppTextStyles.bodyStrong.copyWith(
              color: AppColors.textLightPrimary,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          /// AVATAR
          PlayerMiniAvatar(
            username: player.username,
            avatarAsset: player.avatarUrl,
            isMe: false,
          ),

          const SizedBox(width: AppSpacing.md),

          /// USERNAME
          Expanded(
            child: Text(
              player.username,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textLightPrimary,
              ),
            ),
          ),

          /// SCORE
          Text(
            player.score.toString(),
            style: AppTextStyles.bodyStrong.copyWith(
              color: AppColors.textLightPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
