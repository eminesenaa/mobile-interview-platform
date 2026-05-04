// ===================== File: lb_separator.dart =====================
// Purpose:
// Premium separator between list and current user
//
// Updates:
// - No circle container
// - Thicker lines
// - Bigger icon
// - Cleaner minimal look
// =================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '/../../../constants/constants.dart';

class LbSeparator extends StatelessWidget {
  const LbSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          // LEFT LINE
          Expanded(
            child: Container(
              height: 2,
              color: AppColors.textMuted.withOpacity(0.6),
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // CENTER ICON (NO BACKGROUND)
          Icon(
            PhosphorIcons.dotsThree(
              PhosphorIconsStyle.bold,
            ),
            size: 26,
            color: AppColors.textMuted,
          ),

          const SizedBox(width: AppSpacing.sm),

          // RIGHT LINE
          Expanded(
            child: Container(
              height: 2,
              color: AppColors.textMuted.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
