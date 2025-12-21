// lib/pages/question_types/fill_blank/fill_blank_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/constants.dart';
import '../../../models/question.dart';
import '../../../widgets/ai_explanation_sheet.dart';
import '../../../widgets/ai_feedback_widget.dart';
import '../../../widgets/answer_result_banner.dart';
import '../controllers/fill_blank_controller.dart';
import 'widgets/code_template_with_blanks.dart';

class FillBlankView extends StatelessWidget {
  final Question question;

  const FillBlankView({
    super.key,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FillBlankController(question), tag: question.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===================================================
        // TITLE
        // ===================================================
        Text(
          question.title,
          style: AppTextStyles.headline.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // ===================================================
        // QUESTION PROMPT
        // ===================================================
        if ((question.description ?? '').isNotEmpty)
          Text(
            question.description!,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
            ),
          ),

        const SizedBox(height: AppSpacing.lg),

        // ===================================================
        // CODE TEMPLATE WITH INLINE BLANKS (LOCKABLE)
        // ===================================================
        if ((question.codeTemplate ?? '').isNotEmpty)
          Obx(() {
            if (controller.answers.isEmpty) {
              return const SizedBox.shrink();
            }

            final bool locked = controller.isEvaluating.value;

            return AbsorbPointer(
              absorbing: locked,
              child: Opacity(
                opacity: locked ? 0.65 : 1.0,
                child: CodeTemplateWithBlanksView(
                  codeTemplate: question.codeTemplate!,
                  answers: controller.answers,
                  onChanged: controller.updateAnswer,
                ),
              ),
            );
          }),

        const SizedBox(height: AppSpacing.lg),

        // ===================================================
        // AI FEEDBACK (GLOBAL WIDGET)
        // ===================================================
        Obx(() {
          if (!controller.isSubmitted.value) {
            return const SizedBox.shrink();
          }

          if (controller.isEvaluating.value) {
            // Loading görselini intentionally boş bırakıyoruz
            // (Bottom bar zaten sending state gösteriyor)
            return const SizedBox.shrink();
          }

          final res = controller.aiMeta.value;
          if (res == null) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: AnswerResultBanner(
              correct: res.correct,
              earnedXp: controller.earnedXp.value,
              onWhyPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (_) => AiExplanationSheet(
                    explanation: res.explanation,
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }
}
