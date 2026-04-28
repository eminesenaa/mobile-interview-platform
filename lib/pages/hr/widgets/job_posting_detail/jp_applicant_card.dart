import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

/// ===================== APPLICANT CARD =====================
/// Shows:
/// - avatar (initials)
/// - name
/// - education
/// - status chip (accepted/rejected)
/// - OR action buttons (pending)
/// ==========================================================

class JPApplicantCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String status;

  const JPApplicantCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = status == "pending";

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          /// ================= TOP ROW =================
          Row(
            children: [
              /// AVATAR
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  _initials(name),
                  style: AppTextStyles.bodyStrong.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              /// NAME + EDUCATION
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.bodyStrong),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              /// STATUS (only if not pending)
              if (!isPending) _statusChip(),
            ],
          ),

          /// ================= ACTIONS (ONLY PENDING) =================
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                /// ACCEPT BUTTON
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // TODO: controller.acceptApplicant(...)
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Center(
                        child: Text(
                          "✓ Accept",
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                /// REJECT BUTTON
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // TODO: controller.rejectApplicant(...)
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Center(
                        child: Text(
                          "✕ Reject",
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// ================= STATUS CHIP =================
  Widget _statusChip() {
    late Color color;

    switch (status) {
      case "accepted":
        color = AppColors.success;
        break;
      case "rejected":
        color = AppColors.error;
        break;
      default:
        color = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        _statusLabel(status),
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// ================= INITIALS =================
  String _initials(String name) {
    final parts = name.split(" ");
    if (parts.length == 1) return parts[0][0];
    return parts[0][0] + parts[1][0];
  }

  /// ================= STATUS LABEL =================
  String _statusLabel(String status) {
    if (status.isEmpty) return status;
    return status[0].toUpperCase() + status.substring(1);
  }
}
