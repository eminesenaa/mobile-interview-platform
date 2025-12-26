import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../constants/constants.dart';
import '../../../models/exam.dart';
import '../../main_view.dart';
import '../controllers/exam_result_controller.dart';
import '../exam_review_page.dart';

import 'widgets/score_circle.dart';
import 'widgets/answer_summary_row.dart';
import 'widgets/topic_charts.dart';

class ExamResultPage extends StatelessWidget {
  const ExamResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ExamResultController());
    final args = Get.arguments;
    final Exam? exam = args is Exam ? args : null;

    return Scaffold(
      backgroundColor: AppColors.background,

      // ===================================================
      // APP BAR
      // ===================================================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        title: Text(
          'Exam Result',
          style: AppTextStyles.headline,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Get.offAll(() => const MainView(initialIndex: 2));
          },
        ),
      ),

      // ===================================================
      // CONTENT
      // ===================================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===================================================
            // HEADER
            // ===================================================
            Column(
              children: [
                PhosphorIcon(
                  PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                  size: 32,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.sm),

                Text(
                  'You’ve completed the exam.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.title.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: AppSpacing.xs),

                // XP
                Obx(
                  () => Text(
                    'You earned ${c.earnedXp.value} XP!',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                Text(
                  'Here’s a breakdown of your performance.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // ===================================================
            // SCORE
            // ===================================================
            Center(
              child: Obx(
                () => ScoreCircle(
                  score: c.score.value,
                  total: 100,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ===================================================
            // ANSWER SUMMARY
            // ===================================================
            Obx(
              () => AnswerSummaryRow(
                correct: c.correct.value,
                wrong: c.wrong.value,
                unanswered: c.unanswered.value,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ===================================================
            // TOPIC DISTRIBUTION
            // ===================================================
            const TopicCharts(),

            const SizedBox(height: AppSpacing.sm),

            // ===================================================
            // ACTION
            // ===================================================
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final currentExam = c.exam;
                  if (currentExam != null) {
                    final reviewExam = currentExam.copyWith(
                      stats: {
                        'correct': c.correct.value,
                        'wrong': c.wrong.value,
                        'unanswered': c.unanswered.value,
                      },
                    );

                    Get.to(
                      () => const ExamReviewPage(),
                      arguments: reviewExam,
                    );
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textLightPrimary,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Text(
                  'Review Your Exam',
                  style: AppTextStyles.bodyStrong.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLightPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
