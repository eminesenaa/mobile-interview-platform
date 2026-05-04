// ===================== File: hr_dashboard_header.dart =====================
// Purpose:
// Header section for HR Dashboard (CLEAN VERSION)
//
// Changes:
// - Removed avatar
// - Added settings icon (Phosphor)
// - Clickable → navigate to settings
// - Cleaner & more functional UI
// ==========================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../constants/constants.dart';
import '../../settings/hr_settings_page.dart';

class HRDashboardHeader extends StatelessWidget {
  final String companyName;

  const HRDashboardHeader({
    super.key,
    required this.companyName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ===============================
        // LEFT SIDE (TEXTS)
        // ===============================
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome back",
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              companyName,
              style: AppTextStyles.displayLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),

        // ===============================
        // RIGHT SIDE (SETTINGS ICON)
        // ===============================
        InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () {
            Get.to(() => const HrSettingsPage());
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Icon(
              PhosphorIcons.gear(PhosphorIconsStyle.regular),
              size: AppIconSizes.lg,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}