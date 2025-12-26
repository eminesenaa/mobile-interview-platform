import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/constants.dart';
import '../../../models/question.dart';
import '../controllers/exam_review_controller.dart';

import '../../question_types/fill_blank/widgets/text_with_blanks_view.dart';
import '../../question_types/fill_blank/widgets/code_template_with_blanks.dart';

class ReviewFillBlankView extends StatelessWidget {
  final Question question;
  final String examId;

  const ReviewFillBlankView({
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

    // ===================================================
    // BLANK COUNT HELPERS
    // ===================================================
    int _blankCount(String text) {
      final regex = RegExp(r'___');
      return regex.allMatches(text).length;
    }

    // ===================================================
    // ANSWERS RX (EXAM İLE AYNI MANTIK)
    // ===================================================
    RxList<String> _buildAnswersRx(int blanks) {
      final raw = c.answers[question.id];

      if (raw is List) {
        final list = List<String>.from(raw.map((e) => e.toString()));
        while (list.length < blanks) {
          list.add('');
        }
        return RxList<String>.from(list);
      }

      return RxList<String>.filled(blanks, '');
    }

    // ===================================================
    // TEXT / CODE BLANK ANALYSIS
    // ===================================================
    final bool hasTextBlanks =
    (question.description ?? '').contains('___');

    final int textBlankCount = hasTextBlanks
        ? _blankCount(question.description!)
        : 0;

    final int codeBlankCount =
    (question.codeTemplate ?? '').isNotEmpty
        ? _blankCount(question.codeTemplate!)
        : 0;

    // ⚠️ Aynı answers listesi hem text hem code için
    final answersRx =
    _buildAnswersRx(textBlankCount + codeBlankCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===================================================
        // QUESTION DESCRIPTION (INLINE BLANKS VARSA)
        // ===================================================
        if ((question.description ?? '').isNotEmpty && hasTextBlanks)
          AbsorbPointer(
            absorbing: true,
            child: Opacity(
              opacity: 1.0,
              child: TextWithBlanksView(
                text: question.description!,
                answers: answersRx,
                locked: true,
                onChanged: (_) => (_) {},
              ),
            ),
          )

        // ===================================================
        // QUESTION DESCRIPTION (SADE METİN)
        // ===================================================
        else if ((question.description ?? '').isNotEmpty)
          Text(
            question.description!,
            style: AppTextStyles.body.copyWith(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),

        if ((question.description ?? '').isNotEmpty)
          const SizedBox(height: AppSpacing.lg),

        // ===================================================
        // CODE TEMPLATE WITH INLINE BLANKS (READ-ONLY)
        // ===================================================
        if ((question.codeTemplate ?? '').isNotEmpty)
          AbsorbPointer(
            absorbing: true,
            child: Opacity(
              opacity: 1.0,
              child: CodeTemplateWithBlanksView(
                codeTemplate: question.codeTemplate!,
                answers: answersRx,
                onChanged: (_, __) {},
              ),
            ),
          ),

        const SizedBox(height: AppSpacing.md),

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
