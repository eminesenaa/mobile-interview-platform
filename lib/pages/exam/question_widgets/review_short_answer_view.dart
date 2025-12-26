import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/constants.dart';
import '../../../models/question.dart';
import '../controllers/exam_review_controller.dart';
import '../widgets/model_answer_card.dart';
import '../widgets/user_answer_card.dart';

class ReviewShortAnswerView extends StatelessWidget {
  final Question question;
  final String examId;

  const ReviewShortAnswerView({
    super.key,
    required this.question,
    required this.examId,
  });

  @override
  Widget build(BuildContext context) {
    // ---------------------------------------------------
    // Controller (tag güvenli)
    // ---------------------------------------------------
    ExamReviewController c;
    try {
      c = Get.find<ExamReviewController>(tag: examId);
    } catch (_) {
      c = Get.find<ExamReviewController>();
    }

    final savedAnswer = (c.answers[question.id] ?? '').toString().trim();

    // ✅ Model / correct answer
    final String? modelAnswer =
        (question.correctAnswer?.trim().isNotEmpty == true)
            ? question.correctAnswer!.trim()
            : c.correctAnswerFor(question.id)?.trim();

    // ✅ Accepted variants
    final List<String> acceptedVariants = c.acceptedAnswersFor(question.id);

    // ✅ Review status
    final ReviewStatus status = c.reviewStatusFor(question.id);

    // ✅ Verdict colors
    final _VerdictColors vc = _verdictColors(status);

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
        // USER ANSWER (PRIMARY FOCUS)
        // ===================================================
        UserAnswerCard(
          answer: savedAnswer,
          verdictLabel: _verdictLabel(status),
          borderColor: vc.border,
          fillColor: vc.fill,
          labelColor: vc.border,
          collapsedMaxLines: 6,
        ),

        const SizedBox(height: AppSpacing.lg),

        // ===================================================
        // MODEL / ACCEPTED ANSWERS
        // ===================================================
        ModelAnswerCard(
          answer: modelAnswer,
          acceptedAnswers: acceptedVariants,
        ),

        const SizedBox(height: AppSpacing.lg),

        // ===================================================
        // AI EXPLANATION (Outlined Primary Button)
        // ===================================================
        Align(
          alignment: Alignment.center,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(
                color: AppColors.primary,
                width: 1.4,
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

// ===================================================
// LOCAL HELPERS
// ===================================================

String _verdictLabel(ReviewStatus s) {
  switch (s) {
    case ReviewStatus.correct:
      return 'Correct';
    case ReviewStatus.wrong:
      return 'Wrong';
    case ReviewStatus.unanswered:
      return 'Unanswered';
    default:
      return 'Review';
  }
}

class _VerdictColors {
  final Color border;
  final Color? fill;

  const _VerdictColors(this.border, this.fill);
}

_VerdictColors _verdictColors(ReviewStatus s) {
  switch (s) {
    case ReviewStatus.correct:
      return _VerdictColors(
        AppColors.success,
        AppColors.success.withOpacity(0.10),
      );
    case ReviewStatus.wrong:
      return _VerdictColors(
        AppColors.error,
        AppColors.error.withOpacity(0.10),
      );
    case ReviewStatus.unanswered:
      return _VerdictColors(
        AppColors.textMuted,
        AppColors.surfaceMuted,
      );
    default:
      return _VerdictColors(AppColors.border, null);
  }
}
