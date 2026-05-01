// ===================== File: ad_status_card.dart =====================
// Purpose:
// Displays application status (accepted / pending / rejected)
//
// Features:
// - Dynamic UI based on status
// - Colored container
// - Icon + title + description
// - Optional date/time info (accepted)
// ====================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../../constants/constants.dart';

class AdStatusCard extends StatelessWidget {
  final String status;
  final String? date;
  final String? timeRange;

  const AdStatusCard({
    super.key,
    required this.status,
    this.date,
    this.timeRange,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(status);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: config.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= HEADER =================
          Row(
            children: [
              Icon(
                config.icon,
                color: config.color,
                size: AppIconSizes.lg,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  config.title,
                  style: AppTextStyles.title.copyWith(color: config.color),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // ================= DESCRIPTION =================
          Text(
            config.description,
            style: AppTextStyles.body.copyWith(
              color: config.color.withOpacity(0.75),
            ),
          ),

          // ================= ACCEPTED EXTRA =================
          if (status == "accepted") ...[
            const SizedBox(height: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (date != null)
                      _infoChip(PhosphorIcons.calendar(), date!, config.color),
                    const SizedBox(width: AppSpacing.sm),
                    if (timeRange != null)
                      _infoChip(
                          PhosphorIcons.clock(), timeRange!, config.color),
                  ],
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }

  // ================= CHIP =================
  Widget _infoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: AppSpacing.xs),
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

  // ================= CONFIG =================
  _StatusConfig _getConfig(String status) {
    switch (status) {
      case "accepted":
        return _StatusConfig(
          title: "You're invited to interview.",
          description:
              "Congratulations! An interview has been scheduled for you.",
          color: AppColors.success,
          bgColor: AppColors.success.withOpacity(0.08),
          borderColor: AppColors.success.withOpacity(0.3),
          iconBg: AppColors.success.withOpacity(0.15),
          icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.bold),
        );

      case "rejected":
        return _StatusConfig(
          title: "Not Selected",
          description:
              "Unfortunately, you were not selected for this position.",
          color: AppColors.error,
          bgColor: AppColors.error.withOpacity(0.08),
          borderColor: AppColors.error.withOpacity(0.3),
          iconBg: AppColors.error.withOpacity(0.15),
          icon: PhosphorIcons.xCircle(PhosphorIconsStyle.bold),
        );

      case "pending":
      default:
        return _StatusConfig(
          title: "Under Review",
          description:
              "Your application is under review. HR will contact you soon.",
          color: AppColors.warning,
          bgColor: AppColors.warning.withOpacity(0.08),
          borderColor: AppColors.warning.withOpacity(0.3),
          iconBg: AppColors.warning.withOpacity(0.15),
          icon: PhosphorIcons.clock(PhosphorIconsStyle.bold),
        );
    }
  }
}

class _StatusConfig {
  final String title;
  final String description;
  final Color color;
  final Color bgColor;
  final Color borderColor;
  final Color iconBg;
  final IconData icon;

  _StatusConfig({
    required this.title,
    required this.description,
    required this.color,
    required this.bgColor,
    required this.borderColor,
    required this.iconBg,
    required this.icon,
  });
}
