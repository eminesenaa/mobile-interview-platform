// ===================== File: send_decision_message_page.dart =====================
// Purpose:
// Page for sending decision message after Accept / Reject
//
// Features:
// - Reuses decision selector (locked)
// - Message input
// - AI generate
// - Submit
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/constants.dart';
import '../controllers/send_decision_message_controller.dart';

// REUSED
import '../interviews/needs_review/widgets/nd_ai_generate_button.dart';
import '../interviews/needs_review/widgets/nd_result_message_input.dart';
import '../interviews/needs_review/widgets/nd_decision_selector.dart';

class SendDecisionMessagePage extends StatelessWidget {
  final DecisionType decision;
  final Map<String, dynamic> application;
  final String? postingId; // 🔥 Added postingId

  const SendDecisionMessagePage({
    super.key,
    required this.decision,
    required this.application,
    this.postingId,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.put(
      SendDecisionMessageController(
        decision: decision,
        application: application,
        postingId: postingId, // 🔥 Pass postingId
      ),
    );

    final decisionState = RxnBool(
      decision == DecisionType.accept ? true : false,
    );

    return Scaffold(
      backgroundColor: AppColors.background,

      // ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Send Result",
          style: AppTextStyles.headline,
        ),
      ),

      // ================= BODY =================
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= DECISION (REUSED + LOCKED) =================
            Text(
              "DECISION",
              style: AppTextStyles.label.copyWith(fontSize: 13),
            ),

            const SizedBox(height: AppSpacing.sm),

            AbsorbPointer(
              child: NdDecisionSelector(
                decision: decisionState,
                onSelect: (_) {},
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            /// ================= MESSAGE =================
            NdResultMessageInput(
              controller: c.messageController,
              enabled: true,
            ),

            const SizedBox(height: AppSpacing.sm),

            /// ================= AI BUTTON =================
            NdAiGenerateButton(
              onTap: c.generateAiMessage,
            ),

            const Spacer(),

            /// ================= SUBMIT =================
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: c.canSubmit ? c.submit : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: c.isLoading.value
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
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
