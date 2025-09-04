import 'package:flutter/material.dart';

class TimerBadge extends StatelessWidget {
  final int secondsLeft;
  const TimerBadge({super.key, required this.secondsLeft});

  @override
  Widget build(BuildContext context) {
    final minutes = (secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsLeft % 60).toString().padLeft(2, '0');

    Color bg;
    if (secondsLeft <= 60) {
      bg = Colors.red.withOpacity(.15);
    } else if (secondsLeft <= 5 * 60) {
      bg = Colors.orange.withOpacity(.15);
    } else {
      bg = Theme.of(context).colorScheme.primary.withOpacity(.12);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text("$minutes:$seconds",
          style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
