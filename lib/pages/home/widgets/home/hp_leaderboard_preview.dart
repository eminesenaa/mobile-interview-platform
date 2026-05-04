// ===================== File: hp_leaderboard_preview.dart =====================
// Purpose:
// Premium leaderboard preview (Top 3 redesigned)
//
// Features:
// - #1 center (bigger + crown)
// - #2 left, #3 right
// - Avatar image support
// - Clean hierarchy
// ======================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '/../../../constants/constants.dart';

class HpLeaderboardPreview extends StatelessWidget {
  final List top3;
  final dynamic me;

  const HpLeaderboardPreview({
    super.key,
    required this.top3,
    required this.me,
  });

  @override
  Widget build(BuildContext context) {
    if (top3.length < 3) return const SizedBox.shrink();

    final first = top3[0];
    final second = top3[1];
    final third = top3[2];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // ================= TOP 3 =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 🔥 2ND PLACE
              _buildUser(second, rank: 2, isPrimary: false),

              // 🔥 1ST PLACE (CENTER)
              _buildUser(first, rank: 1, isPrimary: true),

              // 🔥 3RD PLACE
              _buildUser(third, rank: 3, isPrimary: false),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // ================= DIVIDER =================
          Container(
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            height: 1,
            color: AppColors.border,
          ),

          // ================= CURRENT USER =================
          if (me != null)
            Row(
              children: [
                // 🔥 RANK CIRCLE (NO #)
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: (me.rank == 1 || me.rank == 2 || me.rank == 3)
                        ? _rankColor(me.rank)
                        : AppColors.surfaceMuted,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "${me.rank}",
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: (me.rank == 1 || me.rank == 2 || me.rank == 3)
                          ? AppColors.textLightPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // 🔥 NAME
                Expanded(
                  child: Text(
                    me.name ?? me.initials ?? "",
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // 🔥 XP
                Text(
                  "${me.xp} XP",
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ================= USER ITEM =================
  Widget _buildUser(dynamic user,
      {required int rank, required bool isPrimary}) {
    final double avatarSize = isPrimary ? 40 : 32;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ================= AVATAR + CROWN =================
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // Crown only for #1
            if (isPrimary)
              Positioned(
                top: -18,
                child: Icon(
                  PhosphorIcons.crownSimple(PhosphorIconsStyle.fill),
                  size: 18,
                  color: AppColors.rankGold,
                ),
              ),

            // Avatar
            CircleAvatar(
              radius: avatarSize,
              backgroundColor: AppColors.primarySoftBackground,
              child: Text(
                user.initials ?? "",
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // ================= RANK BADGE =================
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _rankColor(rank),
            shape: BoxShape.circle,
          ),
          child: Text(
            "$rank",
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textLightPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 6),

        // ================= NAME =================
        Text(
          user.initials ?? "",
          style: AppTextStyles.body,
        ),

        const SizedBox(height: 2),

        // ================= XP =================
        Text(
          "${user.xp} XP",
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  // ================= RANK COLORS =================
  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.rankGold;
      case 2:
        return AppColors.rankSilver;
      case 3:
        return AppColors.rankBronze;
      default:
        return AppColors.primary;
    }
  }
}
