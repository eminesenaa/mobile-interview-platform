// ===================== File: is_footer_text.dart =====================
// Purpose:
// Displays small footer info text
// =====================================================================

import 'package:flutter/material.dart';
import '../../../../../constants/constants.dart';

class IsFooterText extends StatelessWidget {
  const IsFooterText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "Your progress has been saved automatically.",
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textMuted,
      ),
      textAlign: TextAlign.center,
    );
  }
}
