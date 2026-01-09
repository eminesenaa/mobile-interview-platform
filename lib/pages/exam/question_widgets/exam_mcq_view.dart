import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:interview_project/models/question.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/utils/code_language_utils.dart';

import '../../question_types/widgets/read_only_code_block.dart';
import '../controllers/exam_controller.dart';
import 'widgets/exam_option_tile.dart';

class ExamMcqView extends StatefulWidget {
  final Question question;
  final void Function(String? value) onAnswer;
  final VoidCallback onToggleFlag;
  final String examId;

  const ExamMcqView({
    super.key,
    required this.question,
    required this.onAnswer,
    required this.onToggleFlag,
    required this.examId,
  });

  @override
  State<ExamMcqView> createState() => _ExamMcqViewState();
}

class _ExamMcqViewState extends State<ExamMcqView> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    final c = Get.find<ExamController>(tag: widget.examId);
    final prev = c.answers[widget.question.id];
    if (prev is String) {
      _selected = prev;
    }
  }

  void _select(String value) {
    setState(() => _selected = value);
    widget.onAnswer(value);

    final c = Get.find<ExamController>(tag: widget.examId);
    c.saveAnswer(widget.question.id, value);
  }

  void _clear() {
    setState(() => _selected = null);
    widget.onAnswer(null);

    final c = Get.find<ExamController>(tag: widget.examId);
    c.saveAnswer(widget.question.id, null);
  }

  @override
  Widget build(BuildContext context) {
    final options = List<String>.from(widget.question.options ?? const []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===================================================
        // QUESTION TEXT  ✅ (EKLENDİ)
        // ===================================================
        if ((widget.question.description ?? '').isNotEmpty)
          Text(
            widget.question.description!,
            style: AppTextStyles.body.copyWith(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),

        if ((widget.question.description ?? '').isNotEmpty)
          const SizedBox(height: AppSpacing.lg),

        // ===================================================
        // OPTIONAL CODE TEMPLATE (READ ONLY)
        // ===================================================
        if ((widget.question.codeTemplate ?? '').isNotEmpty) ...[
          ReadOnlyCodeBlock(
            code: widget.question.codeTemplate!,
            language: CodeLanguageUtils.resolveLanguageFromTopic(
              widget.question.topic,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // ===================================================
        // OPTIONS
        // ===================================================
        ...options.map(
          (opt) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ExamOptionTile(
              label: opt,
              selected: _selected == opt,
              onTap: () => _select(opt),
            ),
          ),
        ),
      ],
    );
  }
}
