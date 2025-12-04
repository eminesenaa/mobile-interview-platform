// ===================== File: profile/widgets/profile_stats_row.dart =====================

import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../constants/text_styles.dart';
import '../../../constants/constants.dart';

class ProfileStatsRow extends StatelessWidget {
  final int xp;
  final int streak;

  const ProfileStatsRow({
    super.key,
    required this.xp,
    required this.streak,
  });

  Widget _buildCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.headline,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildCard("Total XP", xp.toString()),
        const SizedBox(width: AppSpacing.md),
        _buildCard("Current Streak", streak.toString()),
      ],
    );
  }
}
