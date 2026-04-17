// ===================== File: ci_date_time_row.dart =====================
// Purpose:
// Handles Date & Time selection row (UPDATED)
//
// Design System:
// - Label on top (uppercase, muted)
// - Same style as CITextField
// - Consistent spacing & alignment
// =======================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../constants/constants.dart';
import '../controllers/create_interview_controller.dart';

class CIDateTimeRow extends StatelessWidget {
  const CIDateTimeRow({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateInterviewController>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================= DATE =================
        Expanded(
          child: Obx(() => _DateField(
            label: "Date",
            text: controller.selectedDate.value == null
                ? "Select Date"
                : controller.selectedDate.value!
                .toString()
                .split(" ")[0],
            onTap: () => controller.pickDate(context),
          )),
        ),

        const SizedBox(width: AppSpacing.md),

        // ================= TIME =================
        Expanded(
          child: Obx(() => _DateField(
            label: "Time",
            text: controller.selectedTime.value == null
                ? "Select Time"
                : controller.selectedTime.value!.format(context),
            onTap: () => controller.pickTime(context),
          )),
        ),
      ],
    );
  }
}


/// ===============================
/// DATE FIELD (LABEL + BOX)
/// ===============================
class _DateField extends StatelessWidget {
  final String label;
  final String text;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================= LABEL =================
        Text(
          label.toUpperCase(),
          style: AppTextStyles.label.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: AppSpacing.xs),

        // ================= BOX =================
        GestureDetector(
          onTap: onTap,
          child: Container(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text,
                  style: AppTextStyles.body,
                ),

                // küçük ikon
                Icon(
                  label == "Date"
                      ? PhosphorIcons.calendar()
                      : PhosphorIcons.clock(),
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