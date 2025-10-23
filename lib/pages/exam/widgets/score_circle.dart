import 'package:flutter/material.dart';

import '../../../constants/colors.dart';

/// Big score circle used at the top of the result page.
/// Shows "score / total" inside a bordered circle.
class ScoreCircle extends StatelessWidget {
  final int score;
  final int total;

  const ScoreCircle({
    super.key,
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: primaryColor, // use app primary color
          width: 4,
        ),
      ),
      alignment: Alignment.center,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          children: [
            TextSpan(text: '$score'),
            TextSpan(
              text: ' / $total',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
