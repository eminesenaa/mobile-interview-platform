// lib/pages/exam/review/widgets/review_navigator_sheet.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/constants.dart';
import '../../controllers/exam_review_controller.dart';

class ReviewNavigatorSheet extends StatelessWidget {
  final String examId;

  const ReviewNavigatorSheet({
    super.key,
    required this.examId,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ExamReviewController>(tag: examId);
    final questions = c.exam.questions;

    final width = MediaQuery.of(context).size.width * 0.75;

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadius.xl),
              bottomLeft: Radius.circular(AppRadius.xl),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 16,
                offset: const Offset(-6, 0),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===================================================
                // HEADER
                // ===================================================
                Text(
                  'Question Navigator',
                  style: AppTextStyles.title.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),

                Text(
                  'Correct: ${c.correctCount} • '
                      'Wrong: ${c.wrongCount} • '
                      'Unanswered: ${c.unansweredCount}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ===================================================
                // QUESTIONS GRID
                // ===================================================
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: AppSpacing.sm,
                      mainAxisSpacing: AppSpacing.sm,
                    ),
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final q = questions[index];

                      // 🔥 SADECE STATUS KULLANIYORUZ
                      final status = c.reviewStatusFor(q.id);

                      Color bgColor;
                      Color textColor;

                      switch (status) {
                        case ReviewStatus.correct:
                          bgColor = AppColors.success;
                          textColor = AppColors.surface;
                          break;
                        case ReviewStatus.wrong:
                          bgColor = AppColors.error;
                          textColor = AppColors.surface;
                          break;
                        case ReviewStatus.unanswered:
                        default:
                          bgColor = AppColors.textMuted;
                          textColor = AppColors.surface;
                      }

                      return GestureDetector(
                        onTap: () {
                          c.goToQuestion(index);
                          Get.back();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: bgColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ===================================================
                // LEGEND
                // ===================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _legendItem(AppColors.success, 'Correct'),
                    _legendItem(AppColors.error, 'Wrong'),
                    _legendItem(AppColors.textMuted, 'Unanswered'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
