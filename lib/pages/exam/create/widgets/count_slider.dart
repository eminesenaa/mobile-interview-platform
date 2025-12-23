import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/constants.dart';

class CountSlider extends StatelessWidget {
  final RxInt count; // controller.count

  const CountSlider({
    super.key,
    required this.count,
  });

  static const List<int> _options = [5, 10, 15, 20];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: _options.map((value) {
          final isSelected = count.value == value;

          return Expanded(
            child: GestureDetector(
              onTap: () => count.value = value,
              child: AnimatedContainer(
                duration: AppDurations.fast,
                margin: const EdgeInsets.only(right: AppSpacing.sm),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primarySoftBackground
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color:
                        isSelected ? AppColors.primary : AppColors.borderStrong,
                  ),
                  boxShadow: isSelected ? AppShadows.low : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$value',
                  style: AppTextStyles.bodyStrong.copyWith(
                    color:
                        isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
