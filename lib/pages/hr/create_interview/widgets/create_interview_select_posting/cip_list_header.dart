// ===================== File: cip_list_header.dart =====================
// Purpose:
// Displays list metadata and sorting option.
//
// Includes:
// - "X postings ready"
// - Sorting label (Newest first)
//
// ====================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '/../../../../constants/constants.dart';

class CipListHeader extends StatelessWidget {
  final int count;
  final VoidCallback? onSortTap;

  const CipListHeader({
    super.key,
    required this.count,
    this.onSortTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$count POSTINGS READY",
          style: AppTextStyles.label.copyWith(
            fontSize: 13,
          ),
        ),
        GestureDetector(
          onTap: onSortTap,
          child: Row(
            children: [
              Text(
                "Newest first",
                style: AppTextStyles.textButton,
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(
                PhosphorIcons.arrowDown(PhosphorIconsStyle.bold),
                size: AppIconSizes.sm,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
