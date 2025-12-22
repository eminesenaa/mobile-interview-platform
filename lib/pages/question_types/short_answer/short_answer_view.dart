import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/constants.dart';
import '../../../models/question.dart';
import '../../../utils/code_language_utils.dart';
import '../../../widgets/ai_explanation_sheet.dart';
import '../../../widgets/answer_result_banner.dart';
import '../controllers/short_answer_controller.dart';
import '../widgets/difficulty_chip.dart';
import '../widgets/read_only_code_block.dart';
import '../widgets/subtopic_chip.dart';

class ShortAnswerView extends StatelessWidget {
  final Question question;
  final bool locked;
  final ValueChanged<String> onChanged;

  const ShortAnswerView({
    super.key,
    required this.question,
    required this.locked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.put(ShortAnswerController(question), tag: question.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =====================
        // TITLE
        // =====================
        Text(
          question.title,
          style: AppTextStyles.headline.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // =====================
        // DIFFICULTY + SUBTOPICS
        // =====================
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            DifficultyChip(difficulty: question.difficulty),
            ...question.subtopics.map(
              (s) => SubtopicChip(label: s),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // =====================
        // QUESTION TEXT
        // =====================
        if ((question.description ?? '').isNotEmpty)
          Text(
            question.description!,
            style: AppTextStyles.questionText,
          ),

        const SizedBox(height: AppSpacing.md),

        // =====================
        // OPTIONAL CODE TEMPLATE
        // =====================
        if ((question.codeTemplate ?? '').isNotEmpty)
          ReadOnlyCodeBlock(
            code: question.codeTemplate!,
            language: CodeLanguageUtils.resolveLanguageFromTopic(
              question.topic,
            ),
          ),

        const SizedBox(height: AppSpacing.lg),

        // =====================
        // ANSWER INPUT
        // =====================
        AbsorbPointer(
          absorbing: locked,
          child: TextField(
            minLines: 3,
            maxLines: 6,
            onChanged: (v) {
              controller.updateAnswer(v);
              onChanged(v); // 🔑 Runner’a bildir
            },
            decoration: InputDecoration(
              hintText: 'Type your answer...',
              filled: true,
              fillColor: AppColors.surfaceMuted,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: AppColors.border),
              ),
            ),
            style: AppTextStyles.questionText,
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // =====================
        // AI RESULT
        // =====================
        Obx(() {
          if (!controller.isSubmitted.value ||
              controller.isEvaluating.value ||
              controller.aiMeta.value == null) {
            return const SizedBox.shrink();
          }

          final res = controller.aiMeta.value!;

          return AnswerResultBanner(
            correct: res.correct,
            earnedXp: controller.earnedXp.value,
            onWhyPressed: () {
              showDialog(
                context: context,
                builder: (_) => AiExplanationSheet(
                  explanation: res.explanation,
                ),
              );
            },
          );
        }),
      ],
    );
  }
}
