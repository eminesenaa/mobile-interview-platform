// ===================== File: ep_info_row.dart =====================
// Purpose:
// Displays label + value row (read-only or clickable)
//
// =====================================================================

import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

class EpInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;

  const EpInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LABEL
              Text(
                label,
                style: AppTextStyles.label.copyWith(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),

              const SizedBox(height: 4),

              // VALUE
              Text(
                value,
                style: AppTextStyles.bodyStrong,
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
