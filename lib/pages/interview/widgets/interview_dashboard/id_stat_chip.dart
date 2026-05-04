// ===================== File: id_stat_chip.dart =====================
// Purpose:
// Premium stat chip with neutral background + colored indicator dot
//
// Design:
// - Soft gray background
// - Subtle border
// - Colored dot (status indicator)
// - Clean typography
// ===================================================================

import 'package:flutter/material.dart';

import '../../../../constants/constants.dart';

class IdStatChip extends StatelessWidget {
  final String text;
  final Color color;

  const IdStatChip({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ================= DOT =================
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // ================= TEXT =================
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
