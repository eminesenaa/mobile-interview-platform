import 'package:flutter/material.dart';

/// Shows the model/expected answer for a short-answer question.
/// - Accepts a single `answer` and/or a list of `acceptedAnswers`
/// - If both provided, shows the main model answer first, then a bulleted list of variants
/// - Subtle blue styling by default, customizable via colors
class ModelAnswerCard extends StatelessWidget {
  final String? answer;
  final List<String>? acceptedAnswers;

  final Color? borderColor;
  final Color? fillColor;
  final String title;

  const ModelAnswerCard({
    super.key,
    this.answer,
    this.acceptedAnswers,
    this.borderColor,
    this.fillColor,
    this.title = 'Model Answer',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final border = borderColor ?? cs.primary;
    final fill = fillColor ?? cs.primary.withOpacity(0.06);
    final variants = (acceptedAnswers ?? []).where((e) => e.trim().isNotEmpty).toList();

    final hasMain = (answer != null && answer!.trim().isNotEmpty);
    final hasVariants = variants.isNotEmpty;

    if (!hasMain && !hasVariants) {
      // Nothing to show
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1.2),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),

          // Main model answer
          if (hasMain)
            Text(
              answer!.trim(),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
            ),

          // Divider if both present
          if (hasMain && hasVariants) const SizedBox(height: 10),
          if (hasMain && hasVariants) const Divider(height: 1),

          // Accepted variants (bulleted)
          if (hasVariants) const SizedBox(height: 8),
          if (hasVariants)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accepted Variants',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                ...variants.map(
                      (v) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•  '),
                        Expanded(
                          child: Text(
                            v.trim(),
                            style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
