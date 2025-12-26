import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/models/question.dart';

import '../../../../constants/constants.dart';

class TypesPicker extends StatelessWidget {
  final RxSet<QuestionType> selected;    // controller.types
  final RxList<QuestionType> options;    // controller.availableTypes

  const TypesPicker({
    super.key,
    required this.selected,
    required this.options,
  });

  String _label(QuestionType t) {
    switch (t) {
      case QuestionType.mcq:
        return 'MCQ';
      case QuestionType.shortAnswer:
        return 'Short Answer';
      case QuestionType.coding:
        return 'Coding';
      case QuestionType.fillBlank:
        return 'Fill Blank';
      case QuestionType.debugging:
        return 'Debugging';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: options.map((qt) {
          final isSelected = selected.contains(qt);

          return FilterChip(
            label: Text(
              _label(qt),
              style: AppTextStyles.bodyStrong.copyWith(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ),
            selected: isSelected,
            onSelected: (_) {
              isSelected
                  ? selected.remove(qt)
                  : selected.add(qt);
            },

            // ✅ SELECTED STATE (aynı kaldı)
            selectedColor: AppColors.primarySoftBackground,
            checkmarkColor: AppColors.primary,

            // ✅ UNSELECTED BORDER FIX
            side: BorderSide(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.35)
                  : AppColors.borderStrong,
            ),

            // ✅ SHAPE (chip + button uyumu)
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          );
        }).toList(),
      ),
    );
  }
}
