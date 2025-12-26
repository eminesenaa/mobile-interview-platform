import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/constants.dart';
import '../../controllers/exam_controller.dart';

class ExamNavigatorSheet extends StatelessWidget {
  final String examId;

  const ExamNavigatorSheet({
    super.key,
    required this.examId,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ExamController>(tag: examId);
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
                  'Total: ${questions.length} | Answered: ${c.answeredCount}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ===================================================
                // QUESTIONS GRID
                // ===================================================
                Expanded(
                  child: SingleChildScrollView(
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: AppSpacing.sm,
                        mainAxisSpacing: AppSpacing.sm,
                      ),
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        final q = questions[index];
                        final answered = c.answers.containsKey(q.id);
                        final flagged = c.flaggedQuestions.contains(q.id);

                        Color bgColor;
                        Color textColor;

                        if (flagged) {
                          bgColor = AppColors.primaryAccent;
                          textColor = AppColors.surface;
                        } else if (answered) {
                          bgColor = AppColors.success;
                          textColor = AppColors.surface;
                        } else {
                          bgColor = AppColors.surfaceMuted;
                          textColor = AppColors.textSecondary;
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
                ),

                const SizedBox(height: AppSpacing.lg),

                // ===================================================
                // LEGEND
                // ===================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _legendItem(
                      AppColors.success,
                      'Answered',
                    ),
                    _legendItem(
                      AppColors.surfaceMuted,
                      'Not Answered',
                    ),
                    _legendItem(
                      AppColors.primaryAccent,
                      'Flagged',
                    ),
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
