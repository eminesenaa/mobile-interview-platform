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
    /// ❌ Non-host
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
      child: Text(
        isEnabled ? 'Start Game' : 'Waiting players...',
        style: AppTextStyles.bodyStrong.copyWith(
          color: isEnabled
              ? Colors.white
              : AppColors.textLightPrimary.withOpacity(0.5),
        ),
      ),
    );
  }
}
