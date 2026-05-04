import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/../../../../constants/constants.dart';

class CITextEditDialog extends StatefulWidget {
  final String title;
  final String initialValue;
  final String hint;
  final Function(String) onSave;

  const CITextEditDialog({
    super.key,
    required this.title,
    required this.initialValue,
    required this.hint,
    required this.onSave,
  });

  @override
  State<CITextEditDialog> createState() => _CITextEditDialogState();
}

class _CITextEditDialogState extends State<CITextEditDialog> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

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
            // ================= TITLE =================
            Text(
              widget.title,
              style: AppTextStyles.title,
            ),

            const SizedBox(height: AppSpacing.md),

            // ================= INPUT =================
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: widget.hint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ================= ACTIONS =================
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final text = controller.text.trim();

                    if (text.isEmpty) return;

                    widget.onSave(text);
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
}
