// lib/pages/exam/question_widgets/exam_short_answer_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/constants.dart';
import '../../../models/question.dart';
import '../../../utils/code_language_utils.dart';
import '../../question_types/widgets/read_only_code_block.dart';
import '../controllers/exam_controller.dart';

class ExamShortAnswerView extends StatefulWidget {
  final Question question;
  final String examId;

  /// ExamPage’den gelen callback
  /// (answeredCount / progress vb. güncellemeleri için)
  final ValueChanged<String?> onAnswerChanged;

  const ExamShortAnswerView({
    super.key,
    required this.question,
    required this.examId,
    required this.onAnswerChanged,
  });

  @override
  State<ExamShortAnswerView> createState() => _ExamShortAnswerViewState();
}

class _ExamShortAnswerViewState extends State<ExamShortAnswerView> {
  late final TextEditingController _controller;
  late final ExamController c;

  @override
  void initState() {
    super.initState();

    // 🔗 Exam controller
    c = Get.find<ExamController>(tag: widget.examId);

    // 🔁 Önceden kaydedilmiş cevap varsa geri yükle
    final prev = c.answers[widget.question.id];
    _controller = TextEditingController(
      text: prev is String ? prev : '',
    );
  }

  @override
  void didUpdateWidget(covariant ExamShortAnswerView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 🔄 Soru değiştiyse controller’ı resetle
    if (oldWidget.question.id != widget.question.id) {
      final prev = c.answers[widget.question.id];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.text = prev is String ? prev : '';
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ===================================================
        // QUESTION TEXT
        // ===================================================
        if ((q.description ?? '').isNotEmpty)
          Text(
            q.description!,
            style: AppTextStyles.body.copyWith(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

        // ===================================================
        // OPTIONAL CODE TEMPLATE (READ ONLY)
        // ===================================================
        if ((q.codeTemplate ?? '').isNotEmpty) ...[
          ReadOnlyCodeBlock(
            code: q.codeTemplate!,
            language: CodeLanguageUtils.resolveLanguageFromTopic(q.topic),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // ===================================================
        // ANSWER INPUT
        // ===================================================
        TextField(
          controller: _controller,
          minLines: 3,
          maxLines: 6,
          onChanged: (value) {
            final val = value.trim();
            widget.onAnswerChanged(val.isEmpty ? null : val);
            c.saveAnswer(widget.question.id, val.isEmpty ? null : val);
          },
          decoration: InputDecoration(
            hintText: 'Type your answer...',
            hintStyle: AppTextStyles.bodySmall.copyWith(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.surfaceMuted,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
          style: AppTextStyles.questionText,
        ),
      ],
    );
  }
}
