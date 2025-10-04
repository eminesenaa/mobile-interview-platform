import 'package:flutter/material.dart';
import '../../../constants/colors.dart';

class ReviewStatsRow extends StatelessWidget {
  final int correct;
  final int wrong;
  final int unanswered;

  const ReviewStatsRow({
    super.key,
    required this.correct,
    required this.wrong,
    required this.unanswered,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(fontWeight: FontWeight.bold);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem("Correct", correct, Colors.green),
          _buildItem("Wrong", wrong, Colors.redAccent),
          _buildItem("Unanswered", unanswered, Colors.grey),
        ],
      ),
    );
  }

  Widget _buildItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          "$count",
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.8),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
