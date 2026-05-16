// ===================== File: jp_publish_button.dart =====================
// Purpose:
// Submit button for posting job
// ========================================================================

import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

import 'package:get/get.dart';
import '../../controllers/hr_job_postings_controller.dart';

class JPPublishButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isEnabled;

  const JPPublishButton({
    super.key,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HrJobPostingsController>();

    return Obx(() {
      final isLoading = controller.isLoading.value;
      final actualEnabled = isEnabled && !isLoading;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: actualEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Ink(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: actualEnabled ? AppColors.primary : AppColors.textMuted.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Center(
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
                      "Publish",
                      style: AppTextStyles.bodyStrong.copyWith(
                        color: actualEnabled ? Colors.white : Colors.white.withOpacity(0.6),
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
        ),
      );
    });
  }
}
