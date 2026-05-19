import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/constants.dart';

/// ===================================================
/// CONFIRM FINISH DIALOG
/// ---------------------------------------------------
/// - Exam bitirme aksiyonu için kullanılır
/// - GetX üzerinden bool döner
/// - UI, Exam ActionBar / Navigator ile uyumludur
/// ===================================================
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

  /// ---------------------------------------------------
  /// STATIC HELPER
  /// ---------------------------------------------------
  /// Kullanım:
  /// final confirmed = await ConfirmFinishDialog.show();
  ///
  /// Her zaman non-null bool döner
  static Future<bool> show() async {
    final bool? res = await Get.dialog<bool>(
      const ConfirmFinishDialog(),
      barrierDismissible: false, // 🔒 Bilinçli karar
    );
    return res ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      elevation: 8,

      // 🔹 Yuvarlak, modern sheet hissi
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),

      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),

      contentPadding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),

      // ===================================================
      // TITLE
      // ===================================================
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: AppTextStyles.title.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),

      // ===================================================
      // CONTENT
      // ===================================================
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ===================================================
          // ACTIONS
          // ===================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  textStyle: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(cancelText),
              ),

              const SizedBox(width: AppSpacing.md), // 👈 yakın ama ayrı

              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(confirmText),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
