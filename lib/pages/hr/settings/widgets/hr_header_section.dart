// ===================== File: hr_header_section.dart =====================
// Purpose:
// Header section for HR Settings Page
//
// Features:
// - Simple company-based header (no user dependency)
// - Uses Phosphor icon
// - Clean and minimal UI
// - Reusable for HR pages
// ======================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../constants/constants.dart';

class HrHeaderSection extends StatelessWidget {
  final String companyName;
  final String? subtitle;

  const HrHeaderSection({
    super.key,
    required this.companyName,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ===============================
        // ICON (COMPANY / HR)
        // ===============================
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            PhosphorIcons.buildingOffice(
              PhosphorIconsStyle.regular,
            ),
            size: 28,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ===============================
        // COMPANY NAME
        // ===============================
        Text(
          companyName,
          style: AppTextStyles.title.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.xs),

        // ===============================
        // SUBTITLE (OPTIONAL)
        // ===============================
        if (subtitle != null)
          Text(
            subtitle!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
