// ===================== File: is_submit_button.dart =====================
// Purpose:
// CTA button to navigate back to Interview Dashboard
//
// Features:
// - Full width premium button
// - Text + arrow (icon RIGHT side)
// - Uses Get.to() navigation (no named routes)
//
// ======================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:get/get.dart';

import '../../../../../constants/constants.dart';
import '../../../pages/interview_dashboard_page.dart';

class IsSubmitButton extends StatelessWidget {
  const IsSubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Get.offAll(() => const InterviewDashboardPage());
        },

        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),

        // ================= CONTENT =================
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TEXT
            Text(
              "Go to Dashboard",
              style: AppTextStyles.body.copyWith(
                color: AppColors.textLightPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            Icon(
              PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
              size: 18,
              color: AppColors.textLightPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
