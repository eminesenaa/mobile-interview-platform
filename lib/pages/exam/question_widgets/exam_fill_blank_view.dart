// lib/pages/exam/question_widgets/exam_fill_blank_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/question.dart';
import '../../../constants/constants.dart';
import '../../question_types/fill_blank/widgets/code_template_with_blanks.dart';
import '../../question_types/fill_blank/widgets/text_with_blanks_view.dart';
import '../controllers/exam_controller.dart';

class ExamFillBlankView extends StatelessWidget {
  final Question question;
  final String examId;

  /// ExamPage’e bildirir
  /// (answeredCount / progress güncellemesi için)
  final ValueChanged<List<String>?> onAnswerChanged;

  const ExamFillBlankView({
    super.key,
    required this.question,
    required this.examId,
    required this.onAnswerChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ExamController>(tag: examId);

    // ===================================================
    // BLANK COUNT (code template içinden)
    // ===================================================
    int _blankCount(String text) {
      final regex = RegExp(r'___');
      return regex.allMatches(text).length;
    }

    // ===================================================
    // ANSWERS RX (HER ZAMAN DOĞRU UZUNLUKTA)
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

    final hasTextBlanks = (question.description ?? '').contains('___');

    final textBlankCount =
        hasTextBlanks ? _blankCount(question.description!) : 0;

    final codeBlankCount = (question.codeTemplate ?? '').isNotEmpty
        ? _blankCount(question.codeTemplate!)
        : 0;

    // ⚠️ Aynı answers listesi hem text hem code için
    final answersRx = _buildAnswersRx(
      textBlankCount + codeBlankCount,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ===================================================
        // QUESTION TEXT
        // ===================================================
        if ((question.description ?? '').isNotEmpty && hasTextBlanks)
          TextWithBlanksView(
            text: question.description!,
            answers: answersRx,
            locked: false,
            onChanged: (index) => (value) {
              answersRx[index] = value;

              final normalized = answersRx.any((e) => e.trim().isNotEmpty)
                  ? answersRx.toList()
                  : null;

              c.saveAnswer(question.id, normalized);
              onAnswerChanged(normalized);
            },
          )
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
        // CODE TEMPLATE WITH INLINE BLANKS (EXAM MODE)
        // ===================================================
        if ((question.codeTemplate ?? '').isNotEmpty)
          CodeTemplateWithBlanksView(
            codeTemplate: question.codeTemplate!,
            answers: answersRx,
            onChanged: (int index, String value) {
              answersRx[index] = value;

              final normalized = answersRx.any((e) => e.trim().isNotEmpty)
                  ? answersRx.toList()
                  : null;

              c.saveAnswer(question.id, normalized);
              onAnswerChanged(normalized);
            },
          ),
      ],
    );
  }
}
