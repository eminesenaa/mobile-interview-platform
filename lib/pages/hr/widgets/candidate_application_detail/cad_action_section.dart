// ===================== FILE: cad_action_section.dart =====================
// Displays action buttons based on status
//
// UPDATE:
// - Added icons to buttons (PhosphorIcons)
// ========================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../constants/constants.dart';

class CADActionSection extends StatelessWidget {
  final String status;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const CADActionSection({
    super.key,
    required this.status,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    if (status == "pending") {
      return Row(
        children: [
          Expanded(
            child: _button(
              "Accept",
              AppColors.success,
              onAccept,
              PhosphorIcons.check(PhosphorIconsStyle.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _button(
              "Reject",
              AppColors.error,
              onReject,
              PhosphorIcons.x(PhosphorIconsStyle.bold),
            ),
          ),
        ],
      );
    }

    if (status == "accepted") {
      return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
              size: 18,
              color: AppColors.success,
            ),
            const SizedBox(width: 6),
            Text(
              "Candidate Accepted",
              style: AppTextStyles.bodyStrong.copyWith(
                color: AppColors.success,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
            size: 18,
            color: AppColors.error,
          ),
          const SizedBox(width: 6),
          Text(
            "Candidate Rejected",
            style: AppTextStyles.bodyStrong.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _button(
    String text,
    Color color,
    VoidCallback onTap,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 🔥 ICON
            Icon(
              icon,
              size: 18,
              color: color,
            ),

            const SizedBox(width: 6),

            /// TEXT
            Text(
              text,
              style: AppTextStyles.bodyStrong.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
