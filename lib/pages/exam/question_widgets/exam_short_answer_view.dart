// lib/pages/exam/question_widgets/exam_short_answer_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../../../models/question.dart';
import '../controllers/exam_controller.dart';

class ExamShortAnswerView extends StatefulWidget {
  final Question question;
  final void Function(String) onAnswerChanged;
  final String examId;

  const ExamShortAnswerView({
    super.key,
    required this.question,
    required this.onAnswerChanged,
    required this.examId,
  });

  @override
  State<ExamShortAnswerView> createState() => _ExamShortAnswerViewState();
}

class _ExamShortAnswerViewState extends State<ExamShortAnswerView> {
  late final TextEditingController _controller;
  late ExamController c;

  @override
  void initState() {
    super.initState();
    c = Get.find<ExamController>(tag: widget.examId);
    final prev = c.answers[widget.question.id];
    _controller = TextEditingController(text: prev is String ? prev : '');

    _controller.addListener(() {
      final text = _controller.text;
      widget.onAnswerChanged(text);
      c.saveAnswer(widget.question.id, text);
    });
  }

  @override
  void didUpdateWidget(covariant ExamShortAnswerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Eğer yeni soru geldiyse, controller metnini güncelle
    if (oldWidget.question.id != widget.question.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final prev = c.answers[widget.question.id];
        _controller.text = prev is String ? prev : '';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _notifyAnswerChanged() {
    widget.onAnswerChanged(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          onChanged: (_) => _notifyAnswerChanged(),
          maxLines: 5,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Type your answer here...',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () => c.toggleFlag(widget.question.id),
              icon: const Icon(Icons.flag_outlined, size: 18),
              label: const Text("Flag"),
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            TextButton.icon(
              onPressed: () {
                _controller.clear();
                _notifyAnswerChanged();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text("Clear"),
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
