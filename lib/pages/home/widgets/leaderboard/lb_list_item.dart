// ===================== File: lb_list_item.dart =====================
// Purpose:
// Leaderboard list item (rank 4+)
//
// Updates:
// - Removed leading zero (04 → 4)
// - Bigger avatar
// - Fixed trend binding
// =================================================================

import 'package:flutter/material.dart';
import '/../../../constants/constants.dart';
import 'lb_trend_badge.dart';

class LbListItem extends StatelessWidget {
  final dynamic user;

  const LbListItem({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md, // 🔥 biraz büyüttük
      ),
      child: Row(
        children: [
          // ================= RANK =================
          SizedBox(
            width: 32,
            child: Text(
              "${user.rank}", // 🔥 padLeft kaldırıldı
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // ================= AVATAR =================
          CircleAvatar(
            radius: 20, // 🔥 büyütüldü (16 → 20)
            backgroundColor: AppColors.primarySoftBackground,
            child: Text(
              user.initials,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ================= NAME + XP =================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name ?? user.initials,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${user.xp} XP",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // ================= TREND =================
          LbTrendBadge(
            value: user.delta,
          ),
        ],
      ),
    );
  }
}
