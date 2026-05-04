// ===================== File: ap_submit_button.dart =====================
// Purpose:
// Submit application button
// ======================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../../constants/constants.dart';

class ApSubmitButton extends StatelessWidget {
  final VoidCallback onTap;

  const ApSubmitButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Submit Application",
              style: AppTextStyles.button.copyWith(
                color: AppColors.textLightPrimary,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
              size: AppIconSizes.md,
              color: AppColors.textLightPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
