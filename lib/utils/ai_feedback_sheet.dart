import 'package:flutter/material.dart';

// + Küçük, bağımsız feedback sheet UI
class _AiFeedbackSheet extends StatelessWidget {
  final String title;
  final double? score;
  final bool correct;
  final String finalAnswer;
  final String explanation;

  const _AiFeedbackSheet({
    required this.title,
    required this.score,
    required this.correct,
    required this.finalAnswer,
    required this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (score != null) Text('Score: ${score!.toStringAsFixed(2)}'),
            Text('Correct: ${correct ? "Yes" : "No"}'),
            const SizedBox(height: 12),
            const Text('Expected / Final Answer:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            Text(finalAnswer),
            const SizedBox(height: 12),
            const Text('Explanation:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            Text(explanation),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
