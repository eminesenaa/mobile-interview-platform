// ===================== File: is_success_icon.dart =====================
// Purpose:
// Displays success icon with circular background & soft ring
// =====================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../../constants/constants.dart';

class IsSuccessIcon extends StatelessWidget {
  const IsSuccessIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
          width: 2,
        ),
        color: AppColors.success.withOpacity(0.08),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.success.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Icon(
          PhosphorIcons.check(PhosphorIconsStyle.bold),
          color: AppColors.success,
          size: 36,
        ),
      ),
    );
  }
}
