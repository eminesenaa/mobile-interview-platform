// ===================== File: ir_review_button.dart =====================
// Purpose:
// CTA button to review interview (exam review page)
//
// Updates:
// - Always primary color
// - White text & icon (readable)
// - Slightly more premium typography
// =====================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../constants/constants.dart';
import '../../../../exam/review/exam_review_page.dart';
import '../../../controllers/interview_results_controller.dart';

class IrReviewButton extends StatelessWidget {
  const IrReviewButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final controller = Get.find<InterviewResultsController>();

          final item = Get.arguments; // detail page'den geliyor

          final exam = await controller.buildInterviewReviewExam(item);

          Get.to(
                () => const ExamReviewPage(),
            arguments: exam,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,

          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),

          elevation: 0,
        ),
        child: Text(
          "Review Interview",
          style: AppTextStyles.bodyStrong.copyWith(
            fontSize: 14,
            color: AppColors.textLightPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
