import 'package:flutter/material.dart';
import '../../../constants/constants.dart';
import '../../../models/question.dart';

class ExamplesSection extends StatelessWidget {
  final List<ExampleCase> examples;

  const ExamplesSection({
    super.key,
    required this.examples,
  });

  @override
  Widget build(BuildContext context) {
    // --------------------------------------------------
    // FILTER VALID EXAMPLES
    // --------------------------------------------------
    final validExamples = examples.where((e) {
      final hasInput = e.input.trim().isNotEmpty && e.input.trim() != '[]';
      final hasOutput = e.output.trim().isNotEmpty && e.output.trim() != '[]';
      final hasExplanation = (e.explanation?.trim().isNotEmpty ?? false);

      return hasInput || hasOutput || hasExplanation;
    }).toList();

    // 🚫 NO VALID EXAMPLES → RENDER NOTHING
    if (validExamples.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(validExamples.length, (i) {
        final e = validExamples[i];
        final isSingle = validExamples.length == 1;
        final title = isSingle ? 'Example' : 'Example ${i + 1}';

        return Padding(
          padding: EdgeInsets.only(
            top: i == 0 ? 0 : AppSpacing.lg,
          ),
          child: _ExampleBlock(
            title: title,
            example: e,
          ),
        );
      }),
    );
  }
}

/// --------------------------------------------------
/// SINGLE EXAMPLE BLOCK (LEETCODE STYLE)
/// --------------------------------------------------
class _ExampleBlock extends StatelessWidget {
  final String title;
  final ExampleCase example;

  const _ExampleBlock({
    required this.title,
    required this.example,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Example / Example 1 / Example 2
        Text(
          '$title:',
          style: AppTextStyles.questionText.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // CONTENT (Indented + vertical line)
        _IndentedBlock(
          children: [
            if (example.input.trim().isNotEmpty && example.input.trim() != '[]')
              _Line(
                label: 'Input',
                value: example.input,
              ),
            if (example.output.trim().isNotEmpty &&
                example.output.trim() != '[]')
              _Line(
                label: 'Output',
                value: example.output,
              ),
            if ((example.explanation ?? '').trim().isNotEmpty)
              _Line(
                label: 'Explanation',
                value: example.explanation!,
              ),
          ],
        ),
      ],
    );
  }
}

/// --------------------------------------------------
/// LEFT LINE + INDENT WRAPPER
/// --------------------------------------------------
class _IndentedBlock extends StatelessWidget {
  final List<Widget> children;

  const _IndentedBlock({required this.children});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 2,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

/// --------------------------------------------------
/// INPUT / OUTPUT / EXPLANATION LINE
/// --------------------------------------------------
class _Line extends StatelessWidget {
  final String label;
  final String value;

  const _Line({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.questionText,
          children: [
            TextSpan(
              text: '$label: ',
              style: AppTextStyles.questionText.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: value,
              style: AppTextStyles.questionText.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
