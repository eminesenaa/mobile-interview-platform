// ===================== File: jd_info_row.dart =====================
// Purpose:
// Reusable row for job info (icon + label + value)
//
// Design:
// - Left: icon + label
// - Right: value
// =================================================================

import 'package:flutter/material.dart';
import '../../../../../constants/constants.dart';

class JdInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const JdInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          // ================= LEFT =================
          Row(
            children: [
              Icon(
                icon,
                size: AppIconSizes.sm,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),

          const Spacer(),

          // ================= VALUE =================
          Text(
            value,
            style: AppTextStyles.bodyStrong,
          ),
        ],
      ),
    );
  }
}
