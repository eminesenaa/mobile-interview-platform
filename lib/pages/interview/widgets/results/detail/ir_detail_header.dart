// ===================== File: ir_detail_header.dart =====================
// Purpose:
// Premium header with responsive layout (NO OVERFLOW)
// =====================================================================

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../../constants/constants.dart';

class IrDetailHeader extends StatelessWidget {
  final String company;
  final String location;
  final String date;
  final String timeRange;
  final String status;
  final String? rankText;

  const IrDetailHeader({
    super.key,
    required this.company,
    required this.location,
    required this.date,
    required this.timeRange,
    required this.status,
    this.rankText,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = status == "pending";

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =====================================================
          // TOP ROW (Company + Badge)
          // =====================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySoftBackground,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  PhosphorIcons.buildings(PhosphorIconsStyle.fill),
                  size: 20,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // Company text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company,
                      style: AppTextStyles.title.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      location,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Badge
              if (isPending)
                _statusBadge("Submitted", AppColors.warning)
              else if (rankText != null)
                _statusBadge(rankText!, AppColors.primary),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // =====================================================
          // DATE & TIME (🔥 WRAP FIX)
          // =====================================================
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (date.isNotEmpty)
                _chip(
                  PhosphorIcons.calendar(),
                  date,
                ),
              if (timeRange.isNotEmpty)
                _chip(
                  PhosphorIcons.clock(),
                  timeRange,
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= CHIP =================
  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ================= STATUS BADGE =================
  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withOpacity(0.25)),
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
