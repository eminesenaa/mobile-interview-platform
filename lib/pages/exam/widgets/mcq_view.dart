import 'package:flutter/material.dart';
import 'package:interview_project/models/question.dart';

class McqView extends StatefulWidget {
  final Question question;
  final void Function(String? value) onAnswer;
  final VoidCallback onToggleFlag;
  const McqView({
    super.key,
    required this.question,
    required this.onAnswer,
    required this.onToggleFlag,
  });

  @override
  State<McqView> createState() => _McqViewState();
}

class _McqViewState extends State<McqView> {
  String? _selected;

  void _clear() {
    setState(() => _selected = null);
    widget.onAnswer(null);
  }

  @override
  Widget build(BuildContext context) {
    final List<String> options = List<String>.from(widget.question.options ?? const []);
    final String questionText =
        widget.question.title ??
            widget.question.description ??
            'Question';

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Soru metni
          Text(questionText, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),

          // Seçenekler (kart hissi)
          ...List.generate(options.length, (i) {
            final label = options[i];
            final value = label;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: RadioListTile<String>(
                value: value,
                groupValue: _selected,
                onChanged: (v) {
                  setState(() => _selected = v);
                  widget.onAnswer(v);
                },
                title: Text(label),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            );
          }),

          const SizedBox(height: 8),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: widget.onToggleFlag,
                icon: const Icon(Icons.flag_outlined),
                label: const Text('Flag'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _clear,
                icon: const Icon(Icons.refresh),
                label: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
