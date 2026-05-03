// ===================== File: ep_input_field.dart =====================
// Purpose:
// Editable input field for profile
//
// =====================================================================

import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

class EpInputField extends StatelessWidget {
  final String label;
  final String initialValue;
  final ValueChanged<String>? onChanged;

  const EpInputField({
    super.key,
    required this.label,
    required this.initialValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        TextFormField(
          initialValue: initialValue.isEmpty ? null : initialValue,
          decoration: InputDecoration(
            hintText: "Enter $label",
            hintStyle: AppTextStyles.body.copyWith(
              color: AppColors.textMuted,
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 2),
          ),
          onChanged: onChanged,
          style: AppTextStyles.body,
        ),
      ],
    );
  }
}
