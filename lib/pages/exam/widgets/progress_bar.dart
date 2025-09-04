import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final int total;
  final int answered;
  const ProgressBar({super.key, required this.total, required this.answered});

  @override
  Widget build(BuildContext context) {
    final value = total == 0 ? 0.0 : answered / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(value: value),
        const SizedBox(height: 6),
        Text("$answered / $total answered",
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
