import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/constants/colors.dart';
import 'package:interview_project/models/question.dart';

class TypesPicker extends StatelessWidget {
  final RxSet<QuestionType> selected;    // controller.types
  final RxList<QuestionType> options;    // controller.availableTypes

  const TypesPicker({super.key, required this.selected, required this.options});

  String _label(QuestionType t) {
    switch (t) {
      case QuestionType.mcq:          return 'MCQ';
      case QuestionType.shortAnswer:  return 'Short Answer';
      case QuestionType.coding:       return 'Coding';
      case QuestionType.fillBlank:    return 'Fill Blank';
      case QuestionType.debugging:    return 'Debugging';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const selectedBg = AppColors.primaryAccent;
    const selectedFg = AppColors.primary;

    return Obx(() => Wrap(
      spacing: 8,
      children: options.map((qt) {
        final sel = selected.contains(qt);
        return FilterChip(
          label: Text(_label(qt)),
          selected: sel,
          onSelected: (_) => sel ? selected.remove(qt) : selected.add(qt),
          selectedColor: selectedBg,
          checkmarkColor: selectedFg,
          labelStyle: TextStyle(
            color: sel ? selectedFg : null,
            fontWeight: sel ? FontWeight.w600 : null,
          ),
        );
      }).toList(),
    ));
  }
}
