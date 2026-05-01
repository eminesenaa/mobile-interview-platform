// ===================== File: ap_section_title.dart =====================
// Purpose:
// Reusable section title for Apply Page
//
// Used in:
// - Contact
// - Application Info
// - Skills
// - Links
// - Resume
// ======================================================================

import 'package:flutter/material.dart';

import '../../../../../constants/text_styles.dart';

class ApSectionTitle extends StatelessWidget {
  final String title;

  const ApSectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: AppTextStyles.label.copyWith(
        fontSize: 13,
      ),
    );
  }
}
