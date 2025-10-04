import 'package:flutter/material.dart';
import 'package:interview_project/constants/colors.dart';
import 'package:interview_project/models/question.dart';

class ExamMcqView extends StatefulWidget {
  final Question question;
  final void Function(String? value) onAnswer;
  final VoidCallback onToggleFlag;
  final bool embedded;
  const ExamMcqView({
    super.key,
    required this.question,
    required this.onAnswer,
    required this.onToggleFlag,
    this.embedded = false,
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
  Widget build(BuildContext context) {
    final List<String> options = List<String>.from(widget.question.options ?? const []);
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
              onPressed: widget.onToggleFlag,
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
    return widget.embedded ? content : Padding(
      padding: const EdgeInsets.only(top: 8),
      child: content,
    );
  }
}
