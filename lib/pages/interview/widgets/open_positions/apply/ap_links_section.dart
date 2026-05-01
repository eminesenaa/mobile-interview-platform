// ===================== File: ap_links_section.dart =====================
// Purpose:
// Optional links (portfolio, github, linkedin)
// ======================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../constants/constants.dart';
import 'ap_input_field.dart';
import 'ap_section_title.dart';

class ApLinksSection extends StatelessWidget {
  final TextEditingController portfolioCtrl;
  final TextEditingController githubCtrl;
  final TextEditingController linkedinCtrl;

  const ApLinksSection({
    super.key,
    required this.portfolioCtrl,
    required this.githubCtrl,
    required this.linkedinCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ApSectionTitle(title: "Links (optional)"),
        const SizedBox(height: AppSpacing.md),
        ApInputField(
          hint: "https://portfolio.com",
          icon: PhosphorIcons.globe(),
          controller: portfolioCtrl,
        ),
        const SizedBox(height: AppSpacing.sm),
        ApInputField(
          hint: "https://github.com/username",
          icon: PhosphorIcons.githubLogo(),
          controller: githubCtrl,
        ),
        const SizedBox(height: AppSpacing.sm),
        ApInputField(
          hint: "https://linkedin.com/in/username",
          icon: PhosphorIcons.linkedinLogo(),
          controller: linkedinCtrl,
        ),
      ],
    );
  }
}
