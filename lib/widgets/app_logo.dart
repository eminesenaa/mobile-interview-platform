import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/text_styles.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AppLogo({
    super.key,
    this.size = 140,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/images/fox_icon.svg',
          width: size,
          height: size,
        ),
        // if (showText) ...[
        //   const SizedBox(height: 10),
        //   Text(
        //     "MIPP",
        //     style: AppTextStyles.displayLarge.copyWith(
        //       fontSize: 46,
        //       fontWeight: FontWeight.w800,
        //       letterSpacing: -1.2,
        //     ),
        //   ),
        // ]
      ],
    );
  }
}
