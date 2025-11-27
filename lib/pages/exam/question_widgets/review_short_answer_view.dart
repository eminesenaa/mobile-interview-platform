import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
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
    final c = Get.find<ExamReviewController>(tag: examId);
    final savedAnswer = (c.answers[question.id] ?? '').toString().trim();

// ✅ Model/Doğru cevap (Question.correctAnswer yoksa controller'dan)
    final String? modelAnswer =
        (question.correctAnswer?.trim().isNotEmpty == true)
            ? question.correctAnswer!.trim()
            : c.correctAnswerFor(question.id)?.trim();

// ✅ Accepted variants (varsa)
    final List<String> acceptedVariants = c.acceptedAnswersFor(question.id);

// ✅ Review durumu (Correct/Wrong/Unanswered)
    final ReviewStatus status = c.reviewStatusFor(question.id);

// ✅ Renkler
    final _VerdictColors vc = _verdictColors(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Kullanıcının cevabı (read-only kart)
        UserAnswerCard(
          answer: savedAnswer,
          verdictLabel: _verdictLabel(status),
          borderColor: vc.border,
          fillColor: vc.fill,
          labelColor: vc.border,
          collapsedMaxLines: 6,
        ),

        const SizedBox(height: 12),
        // ✅ Model / Accepted answers
        ModelAnswerCard(
          answer: modelAnswer,
          acceptedAnswers: acceptedVariants,
        ),
        const SizedBox(height: 12),

        Center(
          child: TextButton(
            onPressed: () {
              c.showAiExplanation(
                questionId: question.id,
                title: 'Explanation: ${question.title}',
              );
            },
            child: const Text(
              "See AI Explanation",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ===== Lokal helper'lar =====
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
      return _VerdictColors(Colors.green, Colors.green.withOpacity(0.10));
    case ReviewStatus.wrong:
      return _VerdictColors(Colors.red, Colors.red.withOpacity(0.10));
    case ReviewStatus.unanswered:
      return _VerdictColors(Colors.grey, Colors.grey.withOpacity(0.15));
    default:
      return _VerdictColors(Colors.grey, null);
  }
}
