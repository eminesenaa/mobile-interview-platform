import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../constants/constants.dart';
import '../../../exam/result/widgets/answer_summary_row.dart';
import '../../../exam/result/widgets/score_circle.dart';
import '../../../exam/result/widgets/topic_charts.dart';
import '../../../exam/review/exam_review_page.dart';
import '../../controllers/hr_candidate_result_controller.dart';


/// ===============================================================
/// HR CANDIDATE RESULT PAGE
/// ---------------------------------------------------------------
/// - Candidate interview widgets (HR view)
/// - Reuses exam result widgets
/// - Adds HR-specific actions
/// ===============================================================
class HrCandidateResultPage extends StatelessWidget {
  const HrCandidateResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;

    final c = Get.put(
      HrCandidateResultController(candidate: args),
    );

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
          'Candidate Result',
          style: AppTextStyles.headline,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
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
            // HEADER (HR VERSION)
            // ===================================================
            Column(
              children: [
                PhosphorIcon(
                  PhosphorIcons.chartBar(PhosphorIconsStyle.fill),
                  size: 32,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.sm),
                Obx(
                  () => Text(
                    "You are reviewing ${c.candidateName.value}'s interview widgets.",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.title.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Here’s a breakdown of the candidate’s performance.',
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
            Obx(
              () => TopicCharts(
                topicRatios: c.topicRatios,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ===================================================
            // ACTION BUTTONS (HR)
            // ===================================================

            /// 🔹 REVIEW ANSWERS !!!
            /// BURASI İÇİN INTERVIEW REVIEW YAZILIRSA ÖZEL DEĞİŞMESİ GEREK SONRADAN
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Get.to(
                    () => const ExamReviewPage(),
                    arguments: c.reviewExamData,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  backgroundColor: AppColors.primary.withOpacity(0.05),
                  side: BorderSide(
                    color: AppColors.primary.withOpacity(0.7),
                    width: 2.6,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Text(
                  'Review Candidate Answers',
                  style: AppTextStyles.bodyStrong.copyWith(
                      fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            /// 🔥 EVALUATE CANDIDATE
            Obx(() {
              /// 🔥 DOĞRU NULL CHECK
              if (c.decision.value != null) {
                final isAccepted = c.decision.value == "accepted";

                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                    horizontal: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: isAccepted
                        ? AppColors.success.withOpacity(0.12)
                        : AppColors.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: isAccepted ? AppColors.success : AppColors.error,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isAccepted ? Icons.check : Icons.close,
                        color: isAccepted ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        isAccepted
                            ? "Candidate Accepted"
                            : "Candidate Rejected",
                        style: AppTextStyles.bodyStrong.copyWith(
                          color: isAccepted
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                );
              }

              /// 🔥 evaluate button
              return SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: c.openEvaluationPage,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: Text(
                    'Evaluate Candidate',
                    style: AppTextStyles.bodyStrong.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textLightPrimary,
                    ),
                  ),
                ),
              );
            })
          ],
        ),
      ),
    );
  }
}
