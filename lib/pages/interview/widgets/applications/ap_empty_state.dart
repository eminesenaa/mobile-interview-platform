// ===================== File: ap_empty_state.dart =====================
// Purpose:
// Empty state when no applications found
//
// Features:
// - Icon + message
// ===================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../constants/constants.dart';

class ApEmptyState extends StatelessWidget {
  const ApEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.briefcase(),
            size: 40,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "No applications found",
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
