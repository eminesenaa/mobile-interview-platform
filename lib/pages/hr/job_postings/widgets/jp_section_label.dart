// ===================== File: jp_section_label.dart =====================
// Purpose:
// Reusable label for form sections (JOB TITLE, LEVEL, etc.)
// Design:
// - Muted
// - Uppercase
// - Consistent across form
// =======================================================================

import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

class JPSectionLabel extends StatelessWidget {
  final String text;

  const JPSectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.label.copyWith(
        color: AppColors.textMuted,
        fontSize: 13,
      ),
    );
  }
}
