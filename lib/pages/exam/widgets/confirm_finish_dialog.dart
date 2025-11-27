import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/constants/colors.dart';

/// Reusable confirm dialog for finishing the exam.
/// Returns `true` if user confirms, otherwise `false`.
class ConfirmFinishDialog extends StatelessWidget {
  final String title;
  final String message;
  final String cancelText;
  final String confirmText;

  const ConfirmFinishDialog({
    super.key,
    this.title = 'Finish Exam',
    this.message = 'Are you sure you want to finish the exam?',
    this.cancelText = 'Cancel',
    this.confirmText = 'Finish',
  });

  /// Show via GetX and return a non-nullable boolean.
  static Future<bool> show() async {
    final bool? res = await Get.dialog<bool>(
      const ConfirmFinishDialog(),
      barrierDismissible: false,
    );
    return res ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        height: 100, // ⬆️ diyalog yüksekliği artırıldı
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                  ),
                  child: Text(cancelText),
                ),
                const SizedBox(width: 24),
                TextButton(
                  onPressed: () => Get.back(result: true),
                  style: TextButton.styleFrom(
                    foregroundColor:
                    AppColors.primary,
                  ),
                  child: Text(confirmText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
