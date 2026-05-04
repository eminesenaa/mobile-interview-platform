// ===================== File: jd_apply_button.dart =====================
// Purpose:
// CTA button for applying to job
//
// Design:
// - Full width
// - Primary color
// - Rounded corners
// ====================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../constants/constants.dart';

class JdApplyButton extends StatelessWidget {
  final VoidCallback onTap;

  const JdApplyButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Apply Now",
              style: AppTextStyles.button,
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
              color: Colors.white,
              size: AppIconSizes.sm,
            ),
          ],
        ),
      ),
    );
  }
}
