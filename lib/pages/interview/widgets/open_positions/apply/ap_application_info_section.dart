// ===================== File: ap_application_info_section.dart =====================
// Purpose:
// Application Info section
//
// Fields:
// - University
// - Department
// ================================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../constants/constants.dart';
import 'ap_input_field.dart';
import 'ap_section_title.dart';

class ApApplicationInfoSection extends StatelessWidget {
  final TextEditingController universityCtrl;
  final TextEditingController departmentCtrl;

  const ApApplicationInfoSection({
    super.key,
    required this.universityCtrl,
    required this.departmentCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ApSectionTitle(title: "Application Info"),
        const SizedBox(height: AppSpacing.md),
        ApInputField(
          hint: "e.g. MIT, ETH Zürich",
          icon: PhosphorIcons.graduationCap(),
          controller: universityCtrl,
        ),
        const SizedBox(height: AppSpacing.sm),
        ApInputField(
          hint: "e.g. Computer Science",
          icon: PhosphorIcons.stack(),
          controller: departmentCtrl,
        ),
      ],
    );
  }
}
