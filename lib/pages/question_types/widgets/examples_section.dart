import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../models/question.dart';

class ExamplesSection extends StatelessWidget {
  final List<ExampleCase> examples;

  const ExamplesSection({super.key, required this.examples});

  @override
  Widget build(BuildContext context) {
    if (examples.isEmpty) return const SizedBox.shrink();

    final s = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: s.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: s.outlineVariant.withOpacity(.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Examples',
              style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          // ...List.generate(examples.length, (i) {
          //   final e = examples[i];
          ...List.generate(examples.length, (i) {
            final e = examples[i];

            if (kDebugMode) {
              debugPrint(
                '[EX_WIDGET] #${i + 1} -> input="${e.input}" | output="${e.output}" | expl="${e.explanation}"',
              );
            }
            return Padding(
              padding:
                  EdgeInsets.only(bottom: i == examples.length - 1 ? 0 : 10),
              child: _ExampleTile(index: i + 1, e: e),
            );
          }),
        ],
      ),
    );
  }
}

class _ExampleTile extends StatelessWidget {
  final int index;
  final ExampleCase e;

  const _ExampleTile({required this.index, required this.e});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final s = Theme.of(context).colorScheme;

    Widget codeBox(String value) => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: s.primary.withOpacity(.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // uzun input/output’lar için
            child: SelectableText(
              (value.isEmpty ? '—' : value),
              style: t.bodySmall?.copyWith(
                fontFamily: 'monospace', // varsa RobotoMono ekleyebilirsin
                height: 1.3,
              ),
            ),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Example $index',
            style: t.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text('Input', style: t.labelSmall),
        codeBox(e.input),
        const SizedBox(height: 6),
        Text('Output', style: t.labelSmall),
        codeBox(e.output),
        if ((e.explanation ?? '').isNotEmpty) ...[
          const SizedBox(height: 6),
          Text('Explanation', style: t.labelSmall),
          codeBox(e.explanation!),
        ],
      ],
    );
  }
}
