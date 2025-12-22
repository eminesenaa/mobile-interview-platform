import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants/constants.dart';

/// Header size variants for auth screens
enum AuthHeaderSize {
  large, // Login
  compact, // Light signup
  tiny, // Form-heavy signup (no scroll)
}

/// Auth screens header
/// - Responsive mascot size
/// - Responsive typography
/// - Same widgets for login & signup
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final AuthHeaderSize size;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.size = AuthHeaderSize.large,
  });

  @override
  Widget build(BuildContext context) {
    late final double mascotHeight;
    late final double spacing;
    late final TextStyle titleStyle;
    late final TextStyle subtitleStyle;

    switch (size) {
      case AuthHeaderSize.large:
        mascotHeight = 180;
        spacing = AppSpacing.lg;
        titleStyle = AppTextStyles.displayLarge;
        subtitleStyle = AppTextStyles.body;
        break;

      case AuthHeaderSize.compact:
        mascotHeight = 130;
        spacing = AppSpacing.md;
        titleStyle = AppTextStyles.headline;
        subtitleStyle = AppTextStyles.bodySmall;
        break;

      case AuthHeaderSize.tiny:
        mascotHeight = 72;
        spacing = AppSpacing.xs;
        titleStyle = AppTextStyles.title;
        subtitleStyle = AppTextStyles.body;
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 🦊 Mascot
        SvgPicture.asset(
          'assets/images/fox_icon_2.svg',
          height: mascotHeight,
        ),

        SizedBox(height: spacing),

        // Title
        Text(
          title,
          style: titleStyle,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.xs),

        // Subtitle
        Text(
          subtitle,
          style: subtitleStyle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
