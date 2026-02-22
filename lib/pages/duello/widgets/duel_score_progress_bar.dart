import 'package:flutter/material.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/models/duel_player.dart';

class DuelScoreProgressBar extends StatelessWidget {
  final List<DuelPlayer> players;
  final String localUserId;
  final int totalQuestions;

  const DuelScoreProgressBar({
    super.key,
    required this.players,
    required this.localUserId,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;

          return SizedBox(
            height: 60,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // =============================
                // TRACK BACKGROUND
                // =============================
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoftBackground,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),

                // =============================
                // AVATARS
                // =============================
                ..._buildAvatars(width),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildAvatars(double width) {
    final Map<double, int> samePositionCounter = {};

    return players.map((player) {
      // 🔥 Absolute progress
      final double progress = totalQuestions == 0
          ? 0
          : (player.correctCount / totalQuestions).clamp(0.0, 1.0);

      final double xPosition = progress * width;

      // Stacking logic (aynı noktada olanları yukarı kaydır)
      final double key = progress;
      final int stackIndex = samePositionCounter[key] ?? 0;
      samePositionCounter[key] = stackIndex + 1;

      final double verticalOffset = stackIndex * 14.0;

      final bool isLocal = player.userId == localUserId;

      return AnimatedPositioned(
        duration: AppDurations.normal,
        curve: Curves.easeInOut,
        left: xPosition - 18,
        top: verticalOffset,
        child: _AvatarBubble(
          correctCount: player.correctCount,
          isLocal: isLocal,
        ),
      );
    }).toList();
  }
}

class _AvatarBubble extends StatelessWidget {
  final int correctCount;
  final bool isLocal;

  const _AvatarBubble({
    required this.correctCount,
    required this.isLocal,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: AppDurations.fast,
      scale: isLocal ? 1.1 : 1.0,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isLocal ? AppColors.primary : AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: isLocal ? AppColors.primaryAccent : AppColors.border,
            width: 2,
          ),
          boxShadow: AppShadows.low,
        ),
        alignment: Alignment.center,
        child: Text(
          correctCount.toString(),
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: isLocal ? AppColors.textLightPrimary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
