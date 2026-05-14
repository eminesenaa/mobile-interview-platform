// ===================== File: id_application_item.dart =====================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../constants/constants.dart';

class IdApplicationItem extends StatelessWidget {
  final Map<String, dynamic> application;
  final VoidCallback? onTap;

  const IdApplicationItem({
    super.key,
    required this.application,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = application["status"] ?? "pending";
    final statusConfig = _getStatusConfig(status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ================= ICON (CLEAN) =================
            Icon(
              _getStatusIcon(status),
              size: AppIconSizes.lg,
              color: statusConfig.color,
            ),
      
            const SizedBox(width: AppSpacing.md),
      
            // ================= TEXT AREA =================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    application["jobTitle"] ?? application["title"] ?? "Unknown Position",
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          application["company"] ?? "Company",
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if ((application["location"] ?? application["workType"]) != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                          ),
                          child: Text(
                            "•",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            application["location"] ?? application["workType"] ?? "",
                            style: AppTextStyles.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
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
      
            const SizedBox(width: AppSpacing.sm),
      
            // ================= CHEVRON (NEW) =================
            Icon(
              PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
              size: AppIconSizes.sm,
              color: AppColors.textMuted, // 👈 subtle
            ),
          ],
        ),
      ),
    );
  }

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

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case "accepted":
        return PhosphorIcons.checkCircle(PhosphorIconsStyle.bold);
      case "rejected":
        return PhosphorIcons.xCircle(PhosphorIconsStyle.bold);
      case "pending":
      default:
        return PhosphorIcons.clock(PhosphorIconsStyle.bold);
    }
  }

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
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusConfig {
  final String label;
  final Color color;

  _StatusConfig(this.label, this.color);
}
