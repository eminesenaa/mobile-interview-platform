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
  final bool isApplied;

  const JdApplyButton({
    super.key,
    required this.onTap,
    this.isApplied = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isApplied ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isApplied ? AppColors.border : AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isApplied ? "Submitted" : "Apply Now",
              style: AppTextStyles.button.copyWith(
                color: isApplied ? AppColors.textMuted : Colors.white,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              isApplied
                  ? PhosphorIcons.checkCircle(PhosphorIconsStyle.bold)
                  : PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
              color: isApplied ? AppColors.textMuted : Colors.white,
              size: AppIconSizes.sm,
            ),
          ],
        ),
      ),
    );
  }
}
