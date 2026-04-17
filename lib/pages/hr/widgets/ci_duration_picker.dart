// ===================== File: ci_duration_picker.dart =====================
// iOS style duration picker (minutes)
// =======================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/constants.dart';
import '../controllers/create_interview_controller.dart';

class CIDurationPicker extends StatelessWidget {
  const CIDurationPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateInterviewController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LABEL
        Text(
          "DURATION",
          style: AppTextStyles.label.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: AppSpacing.xs),

        // BOX
        GestureDetector(
          onTap: () => _openPicker(context, controller),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Obx(() => Text(
              "${controller.selectedDuration.value} minutes",
              style: AppTextStyles.body,
            )),
          ),
        ),
      ],
    );
  }

  void _openPicker(BuildContext context, CreateInterviewController controller) {
    int temp = controller.selectedDuration.value;

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          height: 250,
          color: AppColors.surface,
          child: Column(
            children: [
              // ACTION BAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.setDuration(temp);
                      Get.back();
                    },
                    child: const Text("Done"),
                  ),
                ],
              ),

              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32,
                  scrollController: FixedExtentScrollController(
                    initialItem: temp,
                  ),
                  onSelectedItemChanged: (value) {
                    temp = value;
                  },
                  children: List.generate(
                    121, // 0-120 dakika
                        (index) => Center(
                      child: Text("$index min"),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}