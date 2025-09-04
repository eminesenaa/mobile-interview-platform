import 'package:flutter/material.dart';

class QuestionHeader extends StatelessWidget {
  final int current;
  final int total;
  const QuestionHeader({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Text('Question $current of $total',
          style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
