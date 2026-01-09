import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/constants.dart';
import '../../../models/question.dart';
import '../controllers/exam_review_controller.dart';

class ReviewMcqView extends StatelessWidget {
  final Question question;
  final String examId;

  const ReviewMcqView({
    super.key,
    required this.question,
    required this.examId,
  });

  @override
  Widget build(BuildContext context) {
    // ---------------------------------------------------
    // Controller (tag güvenli erişim)
    // ---------------------------------------------------
    ExamReviewController c;
    try {
      c = Get.find<ExamReviewController>(tag: examId);
    } catch (_) {
      c = Get.find<ExamReviewController>();
    }

    final String? selected = c.answers[question.id] as String?;
    final String? correct = c.correctAnswerFor(question.id);

    final options = question.options ?? const <String>[];

    Widget buildOption(String label) {
      final bool isSelected = selected == label;
      final bool isCorrect = correct == label;
      final bool isUnanswered = selected == null || selected.isEmpty;

      Color borderColor = AppColors.border;
      Color? background;
      IconData icon = Icons.radio_button_off;
      Color iconColor = AppColors.textMuted;

      if (isSelected && isCorrect) {
        // ✅ Doğru seçilmiş
        borderColor = AppColors.success;
        background = AppColors.success.withOpacity(0.08);
        icon = Icons.check_circle;
        iconColor = AppColors.success;
      } else if (isSelected && !isCorrect) {
        // ❌ Yanlış seçilmiş
        borderColor = AppColors.error;
        background = AppColors.error.withOpacity(0.08);
        icon = Icons.cancel;
        iconColor = AppColors.error;
      } else if (!isSelected && isCorrect && !isUnanswered) {
        // ℹ️ Kullanıcı yanlış seçti → doğru cevabı göster
        borderColor = AppColors.success.withOpacity(0.6);
        background = AppColors.success.withOpacity(0.05);
        icon = Icons.check_circle_outline;
        iconColor = AppColors.success;
      }

      return Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }

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
        // OPTIONS (READ-ONLY)
        // ===================================================
        ...options.map(buildOption),

        // ===================================================
        // AI EXPLANATION (Practice ile aynı UX)
        // ===================================================
        const SizedBox(height: AppSpacing.md),
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
