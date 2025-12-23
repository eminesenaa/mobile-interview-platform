import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../constants/constants.dart';
import 'multi_select_sheet.dart';

class MultiSelectField extends StatelessWidget {
  final String title;
  final RxList<String> optionsList;
  final RxSet<String> selectedSet;
  final String buttonLabel;

  const MultiSelectField({
    super.key,
    required this.title,
    required this.optionsList,
    required this.selectedSet,
    required this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 SELECT BUTTON
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
              ),
              builder: (_) => MultiSelectSheet(
                title: title,
                options: optionsList,
                selected: selectedSet,
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ TEXT ÖNCE
              Text(
                buttonLabel,
                style: AppTextStyles.bodyStrong.copyWith(
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // ✅ PHOSPHOR ICON (SAĞDA)
              Icon(
                PhosphorIcons.caretDown(PhosphorIconsStyle.bold),
                size: AppIconSizes.sm,
                color: AppColors.primary,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // 🔹 SELECTED CHIPS
        Obx(() {
          return Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: selectedSet.map((e) {
              return _Chip(
                label: e,
                onRemove: () => selectedSet.remove(e),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _Chip({
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primarySoftBackground,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.chip.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 14,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
