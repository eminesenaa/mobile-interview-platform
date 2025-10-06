import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/constants/colors.dart';
import 'package:interview_project/models/question.dart';

import '../controllers/exam_controller.dart';

class ExamMcqView extends StatefulWidget {
  final Question question;
  final void Function(String? value) onAnswer;
  final VoidCallback onToggleFlag;
  final bool embedded;
  final String examId;

  const ExamMcqView({
    super.key,
    required this.question,
    required this.onAnswer,
    required this.onToggleFlag,
    this.embedded = false,
    required this.examId,
  });

  @override
  State<ExamMcqView> createState() => _ExamMcqViewState();
}

class _ExamMcqViewState extends State<ExamMcqView> {
  String? _selected;

  void _clear() {
    setState(() => _selected = null);
    widget.onAnswer(null);
  }

  @override
  void initState() {
    super.initState();
    // Eğer önceki oturumda cevap verilmişse, onu geri yükle
    final c = Get.find<ExamController>(tag: widget.examId);
    final prevAnswer = c.answers[widget.question.id];
    if (prevAnswer is String) {
      _selected = prevAnswer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> options =
        List<String>.from(widget.question.options ?? const []);
    final String questionText =
        widget.question.title ?? widget.question.description ?? 'Question';

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(questionText, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ...List.generate(options.length, (i) {
          final label = options[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: headlineColor.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                if (Theme.of(context).brightness == Brightness.light)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: RadioListTile<String>(
              value: label,
              groupValue: _selected,
              onChanged: (v) {
                setState(() => _selected = v);
                widget.onAnswer(v);
                // Kaydı shared/state'e yaz
                final c = Get.find<ExamController>(tag: widget.examId);
                c.saveAnswer(widget.question.id, v);
              },
              title: Text(label),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              activeColor: primaryColor,
            ),
          );
        }),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () => Get.find<ExamController>(tag: widget.examId)
                  .toggleFlag(widget.question.id),
              icon: const Icon(Icons.flag_outlined, size: 18),
              label: const Text('Flag'),
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            TextButton.icon(
              onPressed: _clear,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Clear'),
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
            ),
          ],
        ),
      ],
    );

    // embedded modda dış kapsayıcı yok; değilse tek kartlı görünüm (gerekmez bizde)
    return widget.embedded
        ? content
        : Padding(
            padding: const EdgeInsets.only(top: 8),
            child: content,
          );
  }
}
