import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:interview_project/constants/constants.dart';

/// ===============================================================
/// 🚀 LOBBY START BUTTON
/// ===============================================================
///
/// ✔ Host only
/// ✔ Disabled if player < 2
/// ✔ Gradient + glass style
///
class LobbyStartButton extends StatelessWidget {
  final bool isHost;
  final int playerCount;
  final VoidCallback onStart;

  const LobbyStartButton({
    super.key,
    required this.isHost,
    required this.playerCount,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    /// ❌ Non-host → sadece info text
    if (!isHost) {
      return Text(
        'Waiting for host to start...',
        style: AppTextStyles.body.copyWith(
          color: AppColors.textLightPrimary.withOpacity(0.7),
        ),
      );
    }

    final bool isEnabled = playerCount >= 2;

    return GestureDetector(
      onTap: isEnabled ? onStart : null,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),

          /// 🎨 ENABLED → gradient
          gradient: isEnabled
              ? const LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryAccent,
                  ],
                )
              : null,

          /// ❌ DISABLED → muted
          color: isEnabled ? null : Colors.white.withOpacity(0.12),

          /// subtle border
          border: Border.all(
            color: Colors.white.withOpacity(0.25),
          ),

          /// shadow (only enabled)
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.rocketLaunch(PhosphorIconsStyle.fill),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              isEnabled ? 'Start Game' : 'Waiting players...',
              style: AppTextStyles.button.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
