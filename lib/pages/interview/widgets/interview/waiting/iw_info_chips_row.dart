// ===================== File: iw_info_chips_row.dart =====================
// Purpose:
// Displays date & time chips
// ======================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../../constants/constants.dart';


class IwInfoChipsRow extends StatelessWidget {
  final String date;
  final String time;

  const IwInfoChipsRow({
    super.key,
    required this.date,
    required this.time,
  });

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Text(text, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _chip(PhosphorIcons.calendar(PhosphorIconsStyle.fill), date),
        const SizedBox(width: AppSpacing.sm),
        _chip(PhosphorIcons.clock(PhosphorIconsStyle.fill), time),
      ],
    );
  }
}
