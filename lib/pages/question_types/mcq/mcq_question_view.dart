import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/constants.dart';
import '../../../models/question.dart';
import '../../../widgets/ai_explanation_sheet.dart';
import '../../../widgets/answer_result_banner.dart';
import '../controllers/mcq_controller.dart';
import '../widgets/read_only_code_block.dart';

class McqQuestionView extends StatelessWidget {
  final Question question;

  /// Runner’dan gelir – submit sonrası ekranı kilitler
  final bool locked;

  /// Runner’a “cevap seçildi mi?” bilgisini gönderir
  final void Function(Map<String, dynamic>? answer) onChanged;

  const McqQuestionView({
    super.key,
    required this.question,
    required this.locked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(McqController(question), tag: question.id);

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
        // QUESTION TEXT
        // ===================================================
        if ((question.description ?? '').isNotEmpty)
          Text(
            question.description!,
            style: AppTextStyles.questionText,
          ),

        // ===================================================
        // OPTIONAL CODE TEMPLATE (READ ONLY)
        // ===================================================
        if ((question.codeTemplate ?? '').isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          ReadOnlyCodeBlock(
            code: question.codeTemplate!,
          ),
        ],

        const SizedBox(height: AppSpacing.lg),

        // ===================================================
        // OPTIONS
        // ===================================================
        Obx(() {
          return Column(
            children: List.generate(controller.options.length, (index) {
              final option = controller.options[index];
              final bool selected = controller.selectedIndex.value == index;

              return AbsorbPointer(
                absorbing: locked,
                child: InkWell(
                  onTap: () {
                    controller.select(index);
                    onChanged({'index': index});
                  },
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                        width: selected ? 2 : 1.2,
                      ),
                      color: selected
                          ? AppColors.primary.withOpacity(0.04)
                          : AppColors.surface,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // RADIO INDICATOR
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            selected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            size: 20,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),

                        // OPTION CONTENT (CODE-LIKE)
                        Expanded(
                          child: Text(
                            option,
                            style: AppTextStyles.questionText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        }),

        // ===================================================
        // AI RESULT + EXPLANATION
        // ===================================================
        Obx(() {
          if (!controller.isSubmitted.value) {
            return const SizedBox.shrink();
          }

          if (controller.isEvaluating.value) {
            // loading state bottom bar’da
            return const SizedBox.shrink();
          }

          final res = controller.aiResult.value;
          if (res == null) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
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
