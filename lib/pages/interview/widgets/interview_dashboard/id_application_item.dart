// ===================== File: id_application_item.dart =====================
// Purpose:
// Displays a candidate's job application with status (UPDATED UI)
//
// Features:
// - Job title
// - Company + location (single line with dot separator)
// - Status message
// - Status chip (dynamic)
// - Status-colored icon (instead of avatar)
//
// IMPORTANT:
// - Fully dynamic (Map-based, backend-ready)
// - Supports: pending / accepted / rejected
// - Uses Phosphor icons
// ========================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../constants/constants.dart';

class IdApplicationItem extends StatelessWidget {
  final Map<String, dynamic> application;

  const IdApplicationItem({
    super.key,
    required this.application,
  });

  @override
  Widget build(BuildContext context) {
    final status = application["status"] ?? "pending";
    final statusConfig = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= ICON (STATUS COLORED) =================
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusConfig.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              _getStatusIcon(status),
              size: AppIconSizes.md,
              color: statusConfig.color,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // ================= TEXT AREA =================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= TITLE =================
                Text(
                  application["title"] ?? "",
                  style: AppTextStyles.title,
                ),

                const SizedBox(height: AppSpacing.xs),

                // ================= COMPANY + LOCATION =================
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        application["company"] ?? "",
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Dot separator
                    if (application["location"] != null) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                        ),
                        child: Text("•"),
                      ),
                      Flexible(
                        child: Text(
                          application["location"],
                          style: AppTextStyles.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: AppSpacing.xs),

                // ================= MESSAGE =================
                if (application["message"] != null)
                  Text(
                    application["message"],
                    style: AppTextStyles.bodySmall.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // ================= STATUS CHIP =================
          _statusChip(
            statusConfig.label,
            statusConfig.color,
          ),
        ],
      ),
    );
  }

  // =========================================================
  // 🎯 STATUS CONFIG
  // =========================================================
  _StatusConfig _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case "accepted":
        return _StatusConfig("Accepted", AppColors.success);

      case "rejected":
        return _StatusConfig("Rejected", AppColors.error);

      case "pending":
      default:
        return _StatusConfig("Pending", AppColors.warning);
    }
  }

  // =========================================================
  // 🎯 STATUS ICON
  // =========================================================
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case "accepted":
        return PhosphorIcons.checkCircle(PhosphorIconsStyle.fill);

      case "rejected":
        return PhosphorIcons.xCircle(PhosphorIconsStyle.fill);

      case "pending":
      default:
        return PhosphorIcons.clock(PhosphorIconsStyle.fill);
    }
  }

  // =========================================================
  // 🎯 CHIP
  // =========================================================
  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// =========================================================
// 🔹 INTERNAL MODEL
// =========================================================
class _StatusConfig {
  final String label;
  final Color color;

  _StatusConfig(this.label, this.color);
}
