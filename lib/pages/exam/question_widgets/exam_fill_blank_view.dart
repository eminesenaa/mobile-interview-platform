import 'package:flutter/material.dart';
import '../../../models/question.dart';
import '../../../constants/colors.dart';

class ExamFillBlankView extends StatefulWidget {
  final Question question;
  final void Function(Map<int, String>) onAnswerChanged;

  const ExamFillBlankView({
    super.key,
    required this.question,
    required this.onAnswerChanged,
  });

  @override
  State<ExamFillBlankView> createState() => _ExamFillBlankViewState();
}

class _ExamFillBlankViewState extends State<ExamFillBlankView> {
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();

    // Blank sayısı = kaç tane ___ varsa
    final blanks = (widget.question.title.split('___').length - 1).clamp(1, 10);
    for (int i = 0; i < blanks; i++) {
      _controllers[i] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _notifyAnswerChanged() {
    final answers = <int, String>{};
    _controllers.forEach((i, c) {
      answers[i] = c.text;
    });
    widget.onAnswerChanged(answers);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Blank alanları
        ..._controllers.entries.map((entry) {
          final idx = entry.key;
          final controller = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: controller,
              onChanged: (_) => _notifyAnswerChanged(),
              decoration: const InputDecoration(
                hintText: 'Type your answer...', // fill in the blank
                border: OutlineInputBorder(),
              ),
            ),
          );
        }),

        const SizedBox(height: 6),

        // Flag & Clear (MCQ ile aynı)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () {
                // Flag mantığı controller üzerinden handle edilecek
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
                for (final c in _controllers.values) {
                  c.clear();
                }
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
