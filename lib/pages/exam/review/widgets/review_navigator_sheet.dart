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
            boxShadow: AppShadows.medium,
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
                  'Correct: ${c.correctCount} • Wrong: ${c.wrongCount} • Unanswered: ${c.unansweredCount}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ===================================================
                // QUESTION GRID
                // ===================================================
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: AppSpacing.sm,
                      mainAxisSpacing: AppSpacing.sm,
                    ),
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final q = questions[index];
                      final status = c.getQuestionStatus(q.id);

                      // -----------------------------------------------
                      // Status-based styling (soft & readable)
                      // -----------------------------------------------
                      Color bgColor;
                      Color textColor;

                      switch (status) {
                        case ReviewStatus.correct:
                          bgColor = AppColors.success.withOpacity(0.15);
                          textColor = AppColors.success;
                          break;
                        case ReviewStatus.wrong:
                          bgColor = AppColors.error.withOpacity(0.15);
                          textColor = AppColors.error;
                          break;
                        case ReviewStatus.unanswered:
                        default:
                          bgColor = AppColors.surfaceMuted;
                          textColor = AppColors.textMuted;
                          break;
                      }

                      return InkWell(
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
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: AppTextStyles.bodyStrong.copyWith(
                              color: textColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // ===================================================
                // LEGEND
                // ===================================================
                _buildLegend(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===================================================
  // LEGEND
  // ===================================================
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        _LegendItem(
          color: AppColors.success,
          label: 'Correct',
        ),
        _LegendItem(
          color: AppColors.error,
          label: 'Wrong',
        ),
        _LegendItem(
          color: AppColors.textMuted,
          label: 'Unanswered',
        ),
      ],
    );
  }
}

// ===================================================
// LEGEND ITEM (SMALL + SOFT)
// ===================================================
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
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
