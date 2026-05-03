// ===================== File: iw_waiting_card.dart =====================
// Purpose:
// Bottom waiting info card
// ====================================================================

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../../../constants/constants.dart';


class IwWaitingCard extends StatelessWidget {
  final String sessionId;

  const IwWaitingCard({
    super.key,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LoadingAnimationWidget.waveDots(
          color: AppColors.primary,
          size: 28,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          "Waiting for host to start the interview...",
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          "Interview ID • ${sessionId.toUpperCase()}",
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
