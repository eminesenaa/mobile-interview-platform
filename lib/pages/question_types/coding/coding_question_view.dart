import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/question_types/coding/widgets/coding_entry_card.dart';

import '../../../constants/constants.dart';
import '../../../models/question.dart';

import '../../../widgets/ai_explanation_sheet.dart';
import '../../../widgets/answer_result_banner.dart';
import '../../runner/controller/question_runner_controller.dart';
import '../controllers/coding_controller.dart';
import '../widgets/difficulty_chip.dart';
import '../widgets/examples_section.dart';
import '../widgets/subtopic_chip.dart';
import 'coding_editor_page.dart';

class CodingQuestionView extends StatelessWidget {
  final Question question;
  final bool locked;
  final VoidCallback onOpenEditor;

  const CodingQuestionView({
    super.key,
    required this.question,
    required this.locked,
    required this.onOpenEditor,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CodingController(question), tag: question.id);

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
        // CHIPS (DIFFICULTY + SUBTOPICS)
        // ===================================================
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            DifficultyChip(difficulty: question.difficulty),
            ...question.subtopics.map(
              (s) => SubtopicChip(label: s),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // ===================================================
        // QUESTION TEXT
        // ===================================================
        if ((question.description ?? '').isNotEmpty)
          Text(
            question.description!,
            style: AppTextStyles.questionText,
          ),

        const SizedBox(height: AppSpacing.lg),

        // ===================================================
        // EXAMPLES (OPTIONAL)
        // ===================================================
        if (question.examples.isNotEmpty) ...[
          ExamplesSection(examples: question.examples),
          const SizedBox(height: AppSpacing.lg),
        ],

        // ===================================================
        // CODING ENTRY CARD
        // ===================================================
        Obx(() {
          return Opacity(
            opacity: locked ? 0.6 : 1,
            child: CodingEntryCard(
              hasDraft: controller.hasEdited.value,
              onTap: () async {
                final rc = Get.find<QuestionRunnerController>();

                rc.openEditor(question);

                await Get.to(
                  () => CodingEditorPage(question: question),
                );

                rc.closeEditor();
              },
            ),
          );
        }),

        const SizedBox(height: AppSpacing.lg),

        // ===================================================
        // AI RESULT / FEEDBACK
        // ===================================================
        Obx(() {
          if (!controller.isEvaluating.value &&
              controller.aiMeta.value != null) {
            final res = controller.aiMeta.value!;
            return AnswerResultBanner(
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
            );
          }

          return const SizedBox.shrink();
        }),
      ],
    );
  }
}
