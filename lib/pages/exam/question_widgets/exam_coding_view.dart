// lib/pages/exam/question_widgets/exam_coding_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/constants.dart';
import '../../../models/question.dart';
import '../../question_types/widgets/examples_section.dart';
import '../controllers/exam_coding_controller.dart';
import '../controllers/exam_controller.dart';
import 'exam_coding_editor_page.dart';
import '../../question_types/coding/widgets/coding_entry_card.dart';

class ExamCodingView extends StatelessWidget {
  final Question question;
  final String examId;

  /// ExamPage’e bildirir (answeredCount / progress için)
  final ValueChanged<String?> onAnswerChanged;

  const ExamCodingView({
    super.key,
    required this.question,
    required this.examId,
    required this.onAnswerChanged,
  });

  @override
  Widget build(BuildContext context) {
    // 🔥 Controller BURADA oluşturulur
    final codingCtrl = Get.put(
      ExamCodingController(),
      tag: question.id,
      permanent: true, // 🔑 exam bitene kadar yaşasın
    );
    final examController = Get.find<ExamController>(tag: examId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===================================================
        // QUESTION TEXT
        // ===================================================
        if ((question.description ?? '').isNotEmpty)
          Text(
            question.description!,
            style: AppTextStyles.body.copyWith(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
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
        // START CODING
        // ===================================================
        CodingEntryCard(
          hasDraft: examController.answers.containsKey(question.id),
          onTap: () async {
            await Get.to(
              () => ExamCodingEditorPage(
                question: question,
                examId: examId,
              ),
            );

            // 🔑 Editor’dan dönünce mevcut cevabı kontrol et
            final code = examController.answers[question.id];
            onAnswerChanged(code is String ? code : null);
          },
        ),
      ],
    );
  }
}
