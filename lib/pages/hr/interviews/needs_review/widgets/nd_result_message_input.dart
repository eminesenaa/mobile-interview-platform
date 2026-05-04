import 'package:flutter/material.dart';
import '/../../../../constants/constants.dart';

/// ===============================================================
/// ND RESULT MESSAGE INPUT
/// ===============================================================
class NdResultMessageInput extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const NdResultMessageInput({
    super.key,
    required this.controller,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "RESULT MESSAGE",
          style: AppTextStyles.label.copyWith(
            fontSize: 13
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: "Write message to candidate...",
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }
}
