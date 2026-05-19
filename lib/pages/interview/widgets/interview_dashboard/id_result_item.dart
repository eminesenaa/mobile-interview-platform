// ===================== File: id_result_item.dart =====================
// Purpose:
// Displays interview result item (UPDATED)
//
// Improvements:
// - Fixed height (all cards equal)
// - Removed icon block
// - Added left colored status bar
// - Cleaner, more premium layout
// ====================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../constants/constants.dart';
import '../../../../models/interview_result.dart';

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
    String status = "pending";

    if (result["result"] != null) {
      final decision = result["result"].decision;
      status = decision == InterviewDecisionStatus.accepted
          ? "accepted"
          : decision == InterviewDecisionStatus.rejected
          ? "rejected"
          : "pending";
    } else if (result["decision"] != null) {
      status = result["decision"].toString().toLowerCase();
    }

    final config = _getStatusConfig(status);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          height: 92,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              // ================= LEFT STATUS BAR =================
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: config.color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.lg),
                    bottomLeft: Radius.circular(AppRadius.lg),
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // ================= CONTENT =================
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // TITLE
                      Text(
                        result["title"] ?? "",
                        style: AppTextStyles.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: AppSpacing.xs),

                      // SUBTITLE
                      Text(
                        _buildSubtitle(status),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // ================= STATUS CHIP =================
              _statusChip(
                config.label,
                config.color,
              ),

              const SizedBox(width: AppSpacing.sm),

              // ================= ARROW =================
              Icon(
                PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
                size: AppIconSizes.sm,
                color: AppColors.textMuted,
              ),

              const SizedBox(width: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  // ================= STATUS CONFIG =================
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

  // ================= SUBTITLE =================
  String _buildSubtitle(String status) {
    switch (status.toLowerCase()) {
      case "accepted":
        return "You passed this interview.";
      case "rejected":
        return "Application was not successful.";
      case "pending":
      default:
        return "Under HR review.";
    }
  }

  // ================= CHIP =================
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

// ================= INTERNAL MODEL =================
class _StatusConfig {
  final String label;
  final Color color;

  _StatusConfig(this.label, this.color);
}
