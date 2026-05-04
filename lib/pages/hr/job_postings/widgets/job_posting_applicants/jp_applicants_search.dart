import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '/../../../../constants/constants.dart';

/// ===================== APPLICANTS SEARCH =====================
/// Search input for filtering applicants by name/email
///
/// Features:
/// - Icon
/// - Soft background
/// ============================================================

class JPApplicantsSearch extends StatelessWidget {
  final String value;
  final Function(String) onChanged;

  const JPApplicantsSearch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: "Search applicants...",
        hintStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textMuted,
        ),
        prefixIcon: Icon(
          PhosphorIcons.magnifyingGlass(),
          size: 18,
          color: AppColors.textMuted,
        ),
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
    );
  }
}
