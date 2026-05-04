// ===================== File: ep_save_button.dart =====================
// Purpose:
// Save changes button (bottom CTA)
//
// =====================================================================

import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

class EpSaveButton extends StatelessWidget {
  final VoidCallback onTap;

  const EpSaveButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
        ),
        child: Text(
          "Save Changes",
          style: AppTextStyles.bodyStrong.copyWith(
            color: AppColors.textLightPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
