import 'package:flutter/material.dart';

class TimerBadge extends StatelessWidget {
  final int secondsLeft;
  const TimerBadge({super.key, required this.secondsLeft});

  @override
  Widget build(BuildContext context) {
    final minutes = (secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsLeft % 60).toString().padLeft(2, '0');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.access_time_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 4),
        Text(
          "$minutes:$seconds",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white, // ✅ beyaz yazı
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
