// lib/pages/exam/question_widgets/exam_fill_blank_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/question.dart';
import '../../../constants/constants.dart';
import '../../question_types/fill_blank/widgets/code_template_with_blanks.dart';
import '../../question_types/fill_blank/widgets/text_with_blanks_view.dart';
import '../controllers/exam_controller.dart';

class ExamFillBlankView extends StatefulWidget {
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
  State<ExamFillBlankView> createState() => _ExamFillBlankViewState();
}

class _ExamFillBlankViewState extends State<ExamFillBlankView> {
  late final ExamController c;
  late List<String> _answers;

  @override
  void initState() {
    super.initState();
    c = Get.find<ExamController>(tag: widget.examId);
    _initAnswers();
  }

  void _initAnswers() {
    final raw = c.answers[widget.question.id];
    final blanks = _totalBlankCount();

    if (raw is List) {
      final list = List<String>.from(raw.map((e) => e.toString()));
      while (list.length < blanks) {
        list.add('');
      }
      _answers = list;
    } else {
      _answers = List<String>.filled(blanks, '');
    }
  }

  int _blankCount(String text) {
    final regex = RegExp(r'___');
    return regex.allMatches(text).length;
  }

  int _totalBlankCount() {
    final hasTextBlanks = (widget.question.description ?? '').contains('___');
    final textBlankCount = hasTextBlanks ? _blankCount(widget.question.description!) : 0;
    final codeBlankCount = (widget.question.codeTemplate ?? '').isNotEmpty
        ? _blankCount(widget.question.codeTemplate!)
        : 0;
    return textBlankCount + codeBlankCount;
  }

  @override
  void didUpdateWidget(covariant ExamFillBlankView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      setState(() {
        _initAnswers();
      });
    }
  }

  void _onBlankChanged(int index, String value) {
    setState(() {
      _answers[index] = value;
    });

    final normalized = _answers.any((e) => e.trim().isNotEmpty)
        ? List<String>.from(_answers)
        : null;

    c.saveAnswer(widget.question.id, normalized);
    widget.onAnswerChanged(normalized);
  }

  @override
  Widget build(BuildContext context) {
    final hasTextBlanks = (widget.question.description ?? '').contains('___');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ===================================================
        // QUESTION TEXT
        // ===================================================
        if ((widget.question.description ?? '').isNotEmpty && hasTextBlanks)
          TextWithBlanksView(
            text: widget.question.description!,
            answers: _answers,
            locked: false,
            onChanged: (index) => (value) => _onBlankChanged(index, value),
          )
        else if ((widget.question.description ?? '').isNotEmpty)
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
        // CODE TEMPLATE WITH INLINE BLANKS (EXAM MODE)
        // ===================================================
        if ((widget.question.codeTemplate ?? '').isNotEmpty)
          CodeTemplateWithBlanksView(
            codeTemplate: widget.question.codeTemplate!,
            answers: _answers,
            onChanged: _onBlankChanged,
          ),
      ],
    );
  }
}
