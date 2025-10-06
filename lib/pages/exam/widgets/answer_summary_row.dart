import 'package:flutter/material.dart';

class AnswerSummaryRow extends StatelessWidget {
  final int correct;
  final int wrong;
  final int unanswered;

  const AnswerSummaryRow({
    super.key,
    required this.correct,
    required this.wrong,
    required this.unanswered,
  });

  Widget _buildBox(BuildContext context, String label, int value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              "$value",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildBox(context, "Correct", correct, Colors.green),
        _buildBox(context, "Wrong", wrong, Colors.red),
        _buildBox(context, "Unanswered", unanswered, Colors.grey),
      ],
    );
  }
}
