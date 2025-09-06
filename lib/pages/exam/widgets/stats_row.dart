import 'package:flutter/material.dart';

class StatsRow extends StatelessWidget {
  final int answered, flagged, unanswered;
  const StatsRow({super.key, required this.answered, required this.flagged, required this.unanswered});

  @override
  Widget build(BuildContext context) {
    TextStyle? title = Theme.of(context).textTheme.labelMedium;
    TextStyle? value = Theme.of(context).textTheme.titleLarge;

    Widget cell(String t, int v) => Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6), // sadece spacing
        child: Column(
          children: [
            Text(t, style: title),
            const SizedBox(height: 4),
            Text('$v', style: value),
          ],
        ),
      ),
    );

    return Row(
      children: [
        cell('Answered', answered),
        const SizedBox(width: 12),
        cell('Flagged', flagged),
        const SizedBox(width: 12),
        cell('Unanswered', unanswered),
      ],
    );
  }
}
