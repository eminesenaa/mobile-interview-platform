// ===================== File: ir_section_label.dart =====================
// Purpose:
// Section title like "ACCEPTED (2)"
// =====================================================================

import 'package:flutter/material.dart';
import '../../../../../constants/constants.dart';

class IrSectionLabel extends StatelessWidget {
  final String title;

  const IrSectionLabel({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      "$title",
      style: AppTextStyles.label.copyWith(
        color: AppColors.textMuted,
        letterSpacing: 1,
        fontSize: 13,
      ),
    );
  }
}
