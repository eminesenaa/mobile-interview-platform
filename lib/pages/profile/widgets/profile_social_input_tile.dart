// ===================== File: profile_social_input_tile.dart =====================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../constants/text_styles.dart';

/// Clean & reactive social input tile.
/// Uses RxString directly without creating controllers on rebuild.
class ProfileSocialInputTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final RxString rxValue;
  final TextInputType keyboardType;

  const ProfileSocialInputTile({
    super.key,
    required this.label,
    required this.icon,
    required this.rxValue,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return TextField(
        keyboardType: keyboardType,
        controller: TextEditingController(text: rxValue.value)
          ..selection = TextSelection.collapsed(offset: rxValue.value.length),
        onChanged: (v) => rxValue.value = v,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(color: AppColors.border),
          ),
        ),
        style: AppTextStyles.body,
      );
    });
  }
}
