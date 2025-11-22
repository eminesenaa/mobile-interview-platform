import 'package:flutter/material.dart';
import 'package:interview_project/constants/constants.dart';

class ProgressBar extends StatelessWidget {
  final int total;
  final int answered;
  final int current;

  const ProgressBar({
    super.key,
    required this.total,
    required this.answered,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final value = total == 0 ? 0.0 : answered / total;
    const color = AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              '$current of $total Questions',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
