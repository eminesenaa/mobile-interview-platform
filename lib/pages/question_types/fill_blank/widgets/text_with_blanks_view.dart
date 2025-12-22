import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';
import 'blank_input_chip.dart';

class TextWithBlanksView extends StatelessWidget {
  final String text;
  final List<String> answers;
  final ValueChanged<String> Function(int index) onChanged;
  final bool locked;

  const TextWithBlanksView({
    super.key,
    required this.text,
    required this.answers,
    required this.onChanged,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    final parts = text.split('___');

    final spans = <InlineSpan>[];

    for (int i = 0; i < parts.length; i++) {
      // Metin parçası
      if (parts[i].isNotEmpty) {
        spans.add(
          TextSpan(
            text: parts[i],
            style: AppTextStyles.questionText,
          ),
        );
      }

      // Blank (son parça değilse)
      if (i < answers.length) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AbsorbPointer(
                absorbing: locked,
                child: BlankInputChip(
                  value: answers[i],
                  onChanged: (v) => onChanged(i)(v),
                ),
              ),
            ),
          ),
        );
      }
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
