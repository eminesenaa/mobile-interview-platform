import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../../../../constants/constants.dart';
import '../../controllers/hr_candidate_evaluation_controller.dart';
import 'widgets/nd_ai_generate_button.dart';
import 'widgets/nd_decision_selector.dart';
import 'widgets/nd_eval_header_card.dart';
import 'widgets/nd_result_message_input.dart';

/// ===============================================================
/// HR CANDIDATE EVALUATION PAGE (REFACTORED 🔥)
/// ---------------------------------------------------------------
/// - Header Card (candidate + score + rank)
/// - Decision selector (big cards)
/// - Message input
/// - AI generate button
/// - Submit button
/// ===============================================================
class HrCandidateEvaluationPage extends StatelessWidget {
  const HrCandidateEvaluationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(
      HrCandidateEvaluationController(
        candidate: Get.arguments,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,

      // ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        title: Text(
          "Evaluate Candidate",
          style: AppTextStyles.headline,
        ),
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= HEADER CARD =================
            Obx(
              () => NdEvalHeaderCard(
                name: c.candidateName.value,
                interviewTitle: c.interviewTitle.value,
                interviewDate: c.interviewDate.value,
                rank: c.rank.value,
                score: c.score.value,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            /// ================= DECISION =================
            Text(
              "DECISION",
              style: AppTextStyles.label.copyWith(
                fontSize: 13
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            NdDecisionSelector(
              decision: c.decision,
              onSelect: c.selectDecision,
            ),

            const SizedBox(height: AppSpacing.lg),

            /// ================= MESSAGE =================
            Obx(
                  () => NdResultMessageInput(
                controller: c.messageController,
                enabled: c.isDecisionSelected,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            /// ================= AI BUTTON =================
            Obx(
                  () => NdAiGenerateButton(
                onTap: c.isDecisionSelected ? c.generateAiMessage : () {},
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            /// ================= SUBMIT =================
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: c.canSubmit ? c.submitEvaluation : null,
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
                    "Send Decision",
                    style: AppTextStyles.bodyStrong.copyWith(
                      color: AppColors.textLightPrimary,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            /// ================= FOOT NOTE =================
            Center(
              child: Text(
                "Once submitted, this decision cannot be changed.",
                style: AppTextStyles.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
