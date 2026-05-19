// ===================== File: ci_create_button.dart =====================
// Purpose:
// Main CTA button for creating interview
// =======================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/create_interview_controller.dart';
import '/../../../../constants/constants.dart';


class CICreateButton extends StatelessWidget {
  const CICreateButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateInterviewController>();

    return Obx(() {
      final isLoading = controller.isLoading.value;

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : controller.createInterview,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.md),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  "Create Interview",
                  style: AppTextStyles.button,
                ),
        ),
      );
    });
  }
}