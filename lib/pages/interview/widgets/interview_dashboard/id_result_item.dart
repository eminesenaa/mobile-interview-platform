// ===================== File: id_result_item.dart =====================
// Purpose:
// Displays a candidate's interview result (clean + actionable)
//
// Design Decisions:
// - No avatar (single-user context)
// - Left icon (Phosphor)
// - Status chip (accepted / rejected / pending)
// - Navigation arrow (indicates detail page)
// - Minimal + premium look
//
// Status Types:
// - accepted → success
// - rejected → error
// - pending  → warning
// ====================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../constants/constants.dart';

class IdResultItem extends StatelessWidget {
  final Map<String, dynamic> result;
  final VoidCallback? onTap;

  const IdResultItem({
    super.key,
    required this.result,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = result["status"] ?? "pending";

    final config = _getStatusConfig(status);

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
          children: [
            // ================= ICON =================
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: config.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                config.icon,
                color: config.color,
                size: AppIconSizes.md,
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // ================= TEXT =================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE
                  Text(
                    result["title"] ?? "",
                    style: AppTextStyles.title,
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  // SUBTEXT
                  Text(
                    _buildSubtitle(status),
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            // ================= STATUS CHIP =================
            _statusChip(
              config.label,
              config.color,
            ),

            const SizedBox(width: AppSpacing.sm),

            // ================= NAV ARROW =================
            Icon(
              PhosphorIcons.caretRight(),
              size: AppIconSizes.md,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // 🎯 STATUS CONFIG
  // =========================================================
  _StatusConfig _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case "accepted":
        return _StatusConfig(
          "Accepted",
          AppColors.success,
          PhosphorIcons.check(PhosphorIconsStyle.bold),
        );

      case "rejected":
        return _StatusConfig(
          "Rejected",
          AppColors.error,
          PhosphorIcons.x(PhosphorIconsStyle.bold),
        );

      case "pending":
      default:
        return _StatusConfig(
          "Pending",
          AppColors.warning,
          PhosphorIcons.clockUser(),
        );
    }
  }

  // =========================================================
  // 📝 SUBTITLE LOGIC
  // =========================================================
  String _buildSubtitle(String status) {
    switch (status.toLowerCase()) {
      case "accepted":
        return "You passed this interview.";

      case "rejected":
        return "Application was not successful";

      case "pending":
      default:
        return "Under HR review.";
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
        borderRadius: BorderRadius.circular(AppRadius.pill),
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
  final IconData icon;

  _StatusConfig(this.label, this.color, this.icon);
}
