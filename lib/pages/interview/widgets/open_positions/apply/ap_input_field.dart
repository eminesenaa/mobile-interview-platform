// ===================== File: ap_input_field.dart =====================
// Purpose:
// Reusable input field with icon (Apply Page)
//
// Features:
// - Leading icon (Phosphor)
// - Clean UI
// - Controller support
// ====================================================================

import 'package:flutter/material.dart';
import '../../../../../constants/constants.dart';

class ApInputField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final TextEditingController controller;

  const ApInputField({
    super.key,
    required this.hint,
    required this.icon,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: AppTextStyles.bodyStrong,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body.copyWith(
          color: AppColors.textMuted,
        ),
        prefixIcon: Icon(
          icon,
          size: AppIconSizes.md,
          color: AppColors.textMuted,
        ),
        filled: true,
        fillColor: AppColors.surfaceMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
