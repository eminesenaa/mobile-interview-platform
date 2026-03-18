// lib/pages/duello/widgets/result_header.dart

import 'package:flutter/material.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/pages/duello/controllers/duel_result_controller.dart';
import 'package:interview_project/pages/duello/widgets/player_mini_avatar.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// ===============================================================
/// 🧠 RESULT HEADER
/// ===============================================================
///
/// - Win / Lose emoji
/// - Personal message
/// - Entrance animation (scale)
///
class ResultHeader extends StatelessWidget {
  final DuelResultController controller;

  const ResultHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xl),

        /// 🎬 ANIMATED EMOJI
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: AppDurations.slow,
          curve: Curves.elasticOut,
          builder: (_, value, child) =>
              Transform.scale(scale: value, child: child),
          child: Transform.scale(
            scale: 2.0,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                /// AVATAR
                PlayerMiniAvatar(
                  username: controller.username,
                  avatarAsset: controller.avatarUrl,
                  isMe: true,
                ),

                /// 👑 CROWN (SADECE WINNER)
                if (controller.isWinner)
                  Positioned(
                    top: -18,
                    child: Icon(
                      PhosphorIcons.crownSimple(PhosphorIconsStyle.fill),
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),

        /// 💬 MESSAGE
        Column(
          children: [
            /// 🏆 HEADLINE
            Text(
              controller.isWinner ? 'Victory!' : 'So Close!',
              textAlign: TextAlign.center,
              style: AppTextStyles.displayLarge.copyWith(
                fontSize: 26,
                color: AppColors.textLightPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            /// 💬 SUBTEXT
            Text(
              controller.personalMessage,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textLightPrimary.withOpacity(0.7),
                height: 1.4,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
