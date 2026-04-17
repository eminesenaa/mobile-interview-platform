// ===================== File: hr_dashboard_header.dart =====================
// Purpose:
// Header section for HR Dashboard (CLEAN VERSION)
//
// Changes:
// - Removed background container
// - Text now uses primary color
// - Cleaner layout
// ==========================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../constants/constants.dart';

class HRDashboardHeader extends StatelessWidget {
  final String companyName;
  final String? initials;

  const HRDashboardHeader({
    super.key,
    required this.companyName,
    this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),

      child: Row(
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
          // RIGHT SIDE (AVATAR)
          // ===============================
          _Avatar(initials: initials),
        ],
      ),
    );
  }
}


/// ===============================
/// AVATAR WIDGET
/// ===============================
class _Avatar extends StatelessWidget {
  final String? initials;

  const _Avatar({this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,

      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        boxShadow: AppShadows.low,
      ),

      alignment: Alignment.center,

      child: initials != null
          ? Text(
        initials!,
        style: AppTextStyles.bodyStrong,
      )
          : Icon(
        PhosphorIcons.user(),
        size: AppIconSizes.md,
        color: AppColors.textMuted,
      ),
    );
  }
}