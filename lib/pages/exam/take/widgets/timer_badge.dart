import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../constants/constants.dart';

class TimerBadge extends StatelessWidget {
  final int secondsLeft;

  const TimerBadge({
    super.key,
    required this.secondsLeft,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = (secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsLeft % 60).toString().padLeft(2, '0');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          PhosphorIcons.timer(PhosphorIconsStyle.regular),
          size: AppIconSizes.md,
          color: AppColors.textPrimary,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '$minutes:$seconds',
          style: AppTextStyles.bodyStrong.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
