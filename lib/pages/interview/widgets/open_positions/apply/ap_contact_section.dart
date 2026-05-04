// ===================== File: ap_contact_section.dart =====================
// Purpose:
// Contact section of Apply Page
//
// Fields:
// - Email
// - Phone
// - Location
// =======================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../constants/constants.dart';
import 'ap_input_field.dart';
import 'ap_section_title.dart';

class ApContactSection extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController locationCtrl;

  const ApContactSection({
    super.key,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.locationCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ApSectionTitle(title: "Contact"),
        const SizedBox(height: AppSpacing.md),
        ApInputField(
          hint: "you@email.com",
          icon: PhosphorIcons.envelope(),
          controller: emailCtrl,
        ),
        const SizedBox(height: AppSpacing.sm),
        ApInputField(
          hint: "+1 (555) 000-0000",
          icon: PhosphorIcons.phone(),
          controller: phoneCtrl,
        ),
        const SizedBox(height: AppSpacing.sm),
        ApInputField(
          hint: "City, Country",
          icon: PhosphorIcons.mapPin(),
          controller: locationCtrl,
        ),
      ],
    );
  }
}
