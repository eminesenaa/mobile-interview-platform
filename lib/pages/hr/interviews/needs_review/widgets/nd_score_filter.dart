import 'package:flutter/material.dart';
import '/../../../../constants/constants.dart';

class NdScoreFilter extends StatelessWidget {
  final int? selected;
  final Function(int?) onSelected;

  const NdScoreFilter({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final options = const [null, 60, 70, 80, 90];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      children: options.map((e) {
        final isSelected = selected == e;

        return GestureDetector(
          onTap: () => onSelected(e),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.md)
            ),
            child: Text(
              e == null ? "Any" : "$e+",
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}