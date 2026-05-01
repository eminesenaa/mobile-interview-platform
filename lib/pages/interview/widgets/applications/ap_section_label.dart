// ===================== File: ap_section_label.dart =====================
// Purpose:
// Section label for grouped application lists
//
// Features:
// - Uppercase label
// - Optional count (future-ready)
// - Clean spacing
// =======================================================================

import 'package:flutter/material.dart';
import '../../../../../constants/constants.dart';

class ApSectionLabel extends StatelessWidget {
  final String title;
  final int? count;

  const ApSectionLabel({
    super.key,
    required this.title,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: AppTextStyles.label.copyWith(
            fontSize: 13,
          ),
        ),

        // ================= OPTIONAL COUNT =================
        if (count != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            "($count)",
            style: AppTextStyles.bodySmall,
          ),
        ],
      ],
    );
  }
}
