// lib/pages/exam/question_widgets/exam_short_answer_view.dart

import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../models/question.dart';

class ExamShortAnswerView extends StatefulWidget {
  final Question question;
  final void Function(String) onAnswerChanged;

  const ExamShortAnswerView({
    super.key,
    required this.question,
    required this.onAnswerChanged,
  });

  @override
  State<ExamShortAnswerView> createState() => _ExamShortAnswerViewState();
}

class _ExamShortAnswerViewState extends State<ExamShortAnswerView> {
  final TextEditingController _controller = TextEditingController();

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
              onPressed: () {
                // flag mantığı controller’dan handle edilecek
              },
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
