import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wheel_picker/wheel_picker.dart';

import '/../../../../constants/constants.dart';

class CITimePicker {
  static void show({
    required BuildContext context,
    required Function(TimeOfDay) onSelected,
  }) {
    int selectedHour = 12;
    int selectedMinute = 0;
    bool isAm = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.md),

                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildWheel(
                          itemCount: 12,
                          initial: selectedHour % 12,
                          onChanged: (i) =>
                              setState(() => selectedHour = i == 0 ? 12 : i),
                        ),

                        const SizedBox(width: AppSpacing.xs),

                        Text(
                          ":",
                          style: AppTextStyles.title,
                        ),

                        const SizedBox(width: AppSpacing.xs),

                        _buildWheel(
                          itemCount: 60,
                          initial: selectedMinute,
                          onChanged: (i) =>
                              setState(() => selectedMinute = i),
                        ),

                        const SizedBox(width: AppSpacing.md),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _AmPmButton(
                              label: "AM",
                              isSelected: isAm,
                              onTap: () => setState(() => isAm = true),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _AmPmButton(
                              label: "PM",
                              isSelected: !isAm,
                              onTap: () => setState(() => isAm = false),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            int hour = selectedHour % 12;
                            if (!isAm) hour += 12;

                            final time = TimeOfDay(
                              hour: hour,
                              minute: selectedMinute,
                            );

                            onSelected(time);
                            Get.back();
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
Widget _buildWheel({
  required int itemCount,
  required int initial,
  required Function(int) onChanged,
  List<String>? labels,
}) {
  return SizedBox(
    width: 60,
    height: 120,
    child: WheelPicker(
      itemCount: itemCount,
      initialIndex: initial,

      // 🔥 FIX (2 param)
      onIndexChanged: (index, _) => onChanged(index),

      builder: (context, index) {
        final text =
        labels != null ? labels[index] : index.toString().padLeft(2, '0');

        return Center(
          child: Text(
            text,
            style: AppTextStyles.bodyStrong.copyWith(
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
        );
      },

      // ===============================
      // STYLE
      // ===============================
      style: const WheelPickerStyle(
        itemExtent: 36,
        squeeze: 1.2,
        diameterRatio: 1.4,
        surroundingOpacity: 0.3, // 🔥 fade effect
      ),
    ),
  );
}

class _AmPmButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AmPmButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        padding: const EdgeInsets.symmetric(vertical: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
