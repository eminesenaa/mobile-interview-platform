import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

/// ===================== APPLICANT CARD =====================
/// Shows:
/// - avatar (initials)
/// - name
/// - education
/// - status chip (bordered, premium look)
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          /// ================= AVATAR =================
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

          /// ================= NAME + EDUCATION =================
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

          /// ================= STATUS CHIP =================
          _statusChip(),
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

  String _statusLabel(String status) {
    if (status.isEmpty) return status;
    return status[0].toUpperCase() + status.substring(1);
  }
}
