// lib/pages/duello/widgets/result_stats_section.dart

import 'package:flutter/material.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/pages/duello/controllers/duel_result_controller.dart';
import 'result_card.dart';

/// ===============================================================
/// 📊 RESULT STATS SECTION
/// ===============================================================
///
/// Controller'dan gelen tüm statları gösterir
///
class ResultStatsSection extends StatelessWidget {
  final DuelResultController controller;

  const ResultStatsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// ⭐ SCORE
        ResultCard(
          icon: Icons.star,
          label: 'Score',
          value: controller.myScore.toString(),
        ),

        const SizedBox(height: AppSpacing.sm),

        /// ✨ XP
        ResultCard(
          icon: Icons.auto_awesome,
          label: 'XP Earned',
          value: '+${controller.myXp} XP',
          highlight: true,
          trailing: controller.xpApplyError.value
              ? GestureDetector(
            onTap: controller.retryApplyXp,
            child: Text(
              'Retry',
              style: AppTextStyles.bodyStrong.copyWith(
                color: AppColors.warning,
              ),
            ),
          )
              : null,
        ),

        const SizedBox(height: AppSpacing.sm),

        /// 🎯 ACCURACY
        ResultCard(
          icon: Icons.gps_fixed,
          label: 'Accuracy',
          value:
          '%${controller.myAccuracyPercent.toStringAsFixed(0)}',
        ),

        const SizedBox(height: AppSpacing.sm),

        /// 🔥 COMBO
        ResultCard(
          icon: Icons.local_fire_department,
          label: 'Best Combo',
          value: controller.myCombo > 0
              ? '${controller.myCombo}×'
              : '—',
        ),
      ],
    );
  }
}