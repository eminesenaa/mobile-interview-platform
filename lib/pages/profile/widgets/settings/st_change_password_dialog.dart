// ===================== File: st_change_password_dialog.dart =====================
// Purpose:
// Premium centered dialog for changing password
//
// Fixes:
// - Soft gray inputs (no harsh borders)
// - Primary button fixed
// - Eye icon logic fixed
// - Consistent with app design system
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../constants/constants.dart';
import '../../controllers/profile_edit_controller.dart';

class StChangePasswordDialog extends StatefulWidget {
  const StChangePasswordDialog({super.key});

  @override
  State<StChangePasswordDialog> createState() => _StChangePasswordDialogState();
}

class _StChangePasswordDialogState extends State<StChangePasswordDialog> {
  final currentCtrl = TextEditingController();
  final newCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  bool obscure1 = true;
  bool obscure2 = true;
  bool obscure3 = true;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ProfileEditController>();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ================= TITLE =================
            Row(
              children: [
                Icon(
                  PhosphorIcons.lockKey(),
                  size: 20,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: AppSpacing.sm),

                Expanded(
                  child: Text(
                    "Change Password",
                    style: AppTextStyles.title,
                  ),
                ),

                //  CLOSE BUTTON
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(
                    PhosphorIcons.x(),
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // ================= INPUTS =================
            _input(
              controller: currentCtrl,
              hint: "Current Password",
              obscure: obscure1,
              onToggle: () => setState(() => obscure1 = !obscure1),
            ),

            const SizedBox(height: AppSpacing.md),

            _input(
              controller: newCtrl,
              hint: "New Password",
              obscure: obscure2,
              onToggle: () => setState(() => obscure2 = !obscure2),
            ),

            const SizedBox(height: AppSpacing.md),

            _input(
              controller: confirmCtrl,
              hint: "Confirm Password",
              obscure: obscure3,
              onToggle: () => setState(() => obscure3 = !obscure3),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ================= BUTTON =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final current = currentCtrl.text.trim();
                  final next = newCtrl.text.trim();
                  final confirm = confirmCtrl.text.trim();

                  if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
                    Get.snackbar("Error", "All fields are required");
                    return;
                  }

                  if (next != confirm) {
                    Get.snackbar("Error", "Passwords do not match");
                    return;
                  }

                  c.changePassword(current, next);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: Text(
                  "Update Password",
                  style: AppTextStyles.bodyStrong.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= INPUT =================
  Widget _input({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.body.copyWith(
            color: AppColors.textMuted,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? PhosphorIcons.eyeClosed() : PhosphorIcons.eye(),
              size: 18,
              color: AppColors.textMuted,
            ),
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }
}
