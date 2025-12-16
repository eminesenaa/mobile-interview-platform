import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants/constants.dart';

/// Auth screens header
/// - Centered SVG mascot
/// - Title + subtitle
/// - Used ABOVE the card
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🦊 SVG mascot
        SvgPicture.asset(
          'assets/images/fox_icon_2.svg',
          height: 180,
        ),

        const SizedBox(height: AppSpacing.lg),

        // Title
        Text(
          title,
          style: AppTextStyles.displayLarge,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.sm),

        // Subtitle
        Text(
          subtitle,
          style: AppTextStyles.body,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
