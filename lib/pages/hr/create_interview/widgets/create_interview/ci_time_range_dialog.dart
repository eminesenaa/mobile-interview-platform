import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/../../../../constants/constants.dart';
import 'ci_time_picker.dart';

class CITimeRangeDialog extends StatefulWidget {
  final Function(TimeOfDay start, TimeOfDay end) onSave;

  const CITimeRangeDialog({
    super.key,
    required this.onSave,
  });

  @override
  State<CITimeRangeDialog> createState() => _CITimeRangeDialogState();
}

class _CITimeRangeDialogState extends State<CITimeRangeDialog> {
  TimeOfDay start = const TimeOfDay(hour: 13, minute: 30);
  TimeOfDay end = const TimeOfDay(hour: 14, minute: 30);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Edit Time", style: AppTextStyles.title),

            const SizedBox(height: AppSpacing.md),

            // ================= START =================
            _TimeBox(
              label: "Start Time",
              value: _format(start),
              onTap: () {
                CITimePicker.show(
                  context: context,
                  onSelected: (t) {
                    setState(() => start = t);
                  },
                );
              },
            ),

            const SizedBox(height: AppSpacing.md),

            // ================= END =================
            _TimeBox(
              label: "End Time",
              value: _format(end),
              onTap: () {
                CITimePicker.show(
                  context: context,
                  onSelected: (t) {
                    setState(() => end = t);
                  },
                );
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text("Cancel"),
                ),

                const SizedBox(width: AppSpacing.sm),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  onPressed: () {
                    widget.onSave(start, end);
                    Get.back();
                  },
                  child: const Text("Save"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  String _format(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$minute $period";
  }
}

// ================= BOX =================
class _TimeBox extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TimeBox({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodySmall),
            Text(value, style: AppTextStyles.bodyStrong),
          ],
        ),
      ),
    );
  }
}
