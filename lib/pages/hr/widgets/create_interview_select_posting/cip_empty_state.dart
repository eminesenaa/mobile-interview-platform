// ===================== File: cip_empty_state.dart =====================
// Purpose:
// Empty state when no ready postings are available.
//
// ====================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../constants/constants.dart';

class CipEmptyState extends StatelessWidget {
  const CipEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(
            PhosphorIcons.briefcase(),
            size: 48,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            "No ready postings yet",
            style: AppTextStyles.title,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            "Complete candidate reviews to create interviews.",
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
