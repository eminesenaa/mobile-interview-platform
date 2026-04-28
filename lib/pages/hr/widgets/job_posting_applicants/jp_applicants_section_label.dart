import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

/// ===================== SECTION LABEL =====================
/// Displays:
/// - Section title (PENDING / ACCEPTED / REJECTED)
/// - Count badge on right
/// =========================================================

class JPApplicantsSectionLabel extends StatelessWidget {
  final String title;
  final int count;

  const JPApplicantsSectionLabel({
    super.key,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTextStyles.label.copyWith(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ),

        /// Count badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: AppTextStyles.bodySmall,
          ),
        ),
      ],
    );
  }
}
