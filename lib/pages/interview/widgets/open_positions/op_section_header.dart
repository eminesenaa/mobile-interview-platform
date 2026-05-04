// ===================== File: op_section_header.dart =====================
// Purpose:
// Section header for job listings
//
// Features:
// - Title (left)
// - Count (right)
// =====================================================================

import 'package:flutter/material.dart';

import '../../../../constants/constants.dart';

class OpSectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const OpSectionHeader({
    super.key,
    required this.title,
    required this.count,
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
        const Spacer(),
        Text(
          "$count openings",
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
