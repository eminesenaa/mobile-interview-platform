// ===================== File: exam_option_section.dart =====================
// Purpose:
// Wraps exam option cards with consistent spacing
//
// Features:
// - Vertical spacing control
// - Keeps layout clean & reusable
// ======================================================================

import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

class ExamOptionSection extends StatelessWidget {
  final Widget child;

  const ExamOptionSection({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: child,
    );
  }
}
