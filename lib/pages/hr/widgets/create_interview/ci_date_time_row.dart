// ===================== File: ci_date_time_row.dart =====================
// Purpose:
// Date + Start Time + End Time layout (FINAL)
//
// Layout:
// - DATE → full width
// - START & END → 2 column row
// =======================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../constants/constants.dart';
import '../../controllers/create_interview_controller.dart';
import 'ci_time_picker.dart';

class CIDateTimeRow extends StatelessWidget {
  const CIDateTimeRow({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateInterviewController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================= DATE =================
        Obx(() => _DateField(
              label: "Date",
              text: controller.selectedDate.value == null
                  ? "Select Date"
                  : controller.selectedDate.value!.toString().split(" ")[0],
              onTap: () => controller.pickDate(context),
              icon: PhosphorIcons.calendar(),
            )),

        const SizedBox(height: AppSpacing.md),

        // ================= START + END =================
        Row(
          children: [
            // ================= START =================
            Expanded(
              child: Obx(() => _DateField(
                    label: "Start Time",
                    text: controller.selectedStartTime.value == null
                        ? "1:30 PM"
                        : controller.selectedStartTime.value!.format(context),
                    isPlaceholder: controller.selectedStartTime.value == null,
                    onTap: () {
                      CITimePicker.show(
                        context: context,
                        onSelected: controller.setStartTime,
                      );
                    },
                    icon: PhosphorIcons.clock(),
                  )),
            ),

            // ================= DASH =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                "–",
                style: AppTextStyles.title.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),

            // ================= END =================
            Expanded(
              child: Obx(() => _DateField(
                    label: "End Time",
                    text: controller.selectedEndTime.value == null
                        ? "2:30 PM"
                        : controller.selectedEndTime.value!.format(context),
                    isPlaceholder: controller.selectedEndTime.value == null,
                    onTap: () {
                      CITimePicker.show(
                        context: context,
                        onSelected: controller.setEndTime,
                      );
                    },
                    icon: PhosphorIcons.clock(),
                  )),
            ),
          ],
        ),
      ],
    );
  }
}

/// ===============================
/// REUSABLE FIELD
/// ===============================
class _DateField extends StatelessWidget {
  final String label;
  final String text;
  final VoidCallback onTap;
  final IconData icon;
  final bool isPlaceholder;

  const _DateField({
    required this.label,
    required this.text,
    required this.onTap,
    required this.icon,
    this.isPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LABEL
        Text(
          label.toUpperCase(),
          style: AppTextStyles.label.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: AppSpacing.xs),

        // BOX
        GestureDetector(
          onTap: onTap,
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
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: AppTextStyles.body.copyWith(
                      color: isPlaceholder
                          ? AppColors.textMuted.withOpacity(0.7)
                          : AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  icon,
                  size: AppIconSizes.md,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
