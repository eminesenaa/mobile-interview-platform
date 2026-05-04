// ===================== File: lb_me_item.dart =====================
// Purpose:
// Current user row (border highlight version)
//
// Updates:
// - Removed background color
// - Added subtle border
// - Cleaner premium look
// =================================================================

import 'package:flutter/material.dart';
import '/../../../constants/constants.dart';
import 'lb_trend_badge.dart';

class LbMeItem extends StatelessWidget {
  final dynamic me;

  const LbMeItem({super.key, required this.me});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.topicBrightTeal.withOpacity(0.7),
          width: 2.6,
        ),
      ),
      child: Row(
        children: [
          // ================= RANK =================
          SizedBox(
            width: 32,
            child: Text(
              "${me.rank}",
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // ================= AVATAR =================
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primarySoftBackground,
            child: Text(
              me.initials ?? "",
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
                  me.name ?? me.initials ?? "",
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${me.xp} XP",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // ================= TREND =================
          LbTrendBadge(
            value: me.delta,
          ),
        ],
      ),
    );
  }
}