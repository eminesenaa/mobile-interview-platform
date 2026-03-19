import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:interview_project/constants/constants.dart';

/// ===============================================================
/// AnimatedStatusText
/// ---------------------------------------------------------------
/// - Text + animated dots gösterir
/// - Searching / Game Starting gibi durumlar için reusable
/// ===============================================================
class AnimatedStatusText extends StatelessWidget {
  final String text;

  const AnimatedStatusText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: AppTextStyles.headline.copyWith(
            color: AppColors.textLightPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        LoadingAnimationWidget.waveDots(
          color: Colors.white,
          size: 18,
        ),
      ],
    );
  }
}