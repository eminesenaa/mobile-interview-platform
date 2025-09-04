import 'package:flutter/material.dart';

class StatsRow extends StatelessWidget {
  final int answered;
  final int flagged;
  final int unanswered;
  const StatsRow({super.key, required this.answered, required this.flagged, required this.unanswered});

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).colorScheme.surface;
    final textStyle = Theme.of(context).textTheme.labelMedium;

    Widget box(String title, int value) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          children: [
            Text(title, style: textStyle),
            const SizedBox(height: 6),
            Text('$value', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );

    return Row(
      children: [
        box('Answered', answered),
        const SizedBox(width: 12),
        box('Flagged', flagged),
        const SizedBox(width: 12),
        box('Unanswered', unanswered),
      ],
    );
  }
}
