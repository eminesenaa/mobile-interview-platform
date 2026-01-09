import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/constants.dart';
import '../../../models/question.dart';
import '../controllers/exam_review_controller.dart';
import '../question_widgets/review_coding_editor_page.dart';
import '../review/widgets/review_coding_entry_card.dart';

class ReviewCodingView extends StatelessWidget {
  final Question question;
  final String examId;

  const ReviewCodingView({
    super.key,
    required this.question,
    required this.examId,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ExamReviewController>(tag: examId);

    final String savedAnswer = (c.answers[question.id] ?? '').toString().trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===================================================
        // QUESTION DESCRIPTION
        // ===================================================
        if ((question.description ?? '').isNotEmpty) ...[
          Text(
            question.description!,
            style: AppTextStyles.body.copyWith(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // ===================================================
        // CODING ENTRY CARD
        // ===================================================
        Opacity(
          opacity: 0.9,
          child: ReviewCodingEntryCard(
            onTap: () {
              Get.to(
                () => ReviewCodingEditorPage(
                  question: question,
                  examId: examId,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // ===================================================
        // AI EXPLANATION
        // ===================================================
        Align(
          alignment: Alignment.center,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(
                color: AppColors.primary,
                width: 1.2,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              textStyle: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            onPressed: () {
              c.showAiExplanation(
                questionId: question.id,
                title: 'Explanation',
              );
            },
            child: const Text('View Explanation'),
          ),
        ),
      ],
    );
  }
}
