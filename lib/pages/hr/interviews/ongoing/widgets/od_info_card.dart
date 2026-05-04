import 'package:flutter/material.dart';
import '/../../../../constants/constants.dart';

class OngoingInfoCard extends StatelessWidget {
  final String position;
  final String timeRange;
  final String interviewId;

  const OngoingInfoCard({
    super.key,
    required this.position,
    required this.timeRange,
    required this.interviewId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.low,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoItem("POSITION", position),
              ),
              Expanded(
                child: _InfoItem("TIME", timeRange),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // DIVIDER
          Container(
            height: 1,
            width: double.infinity,
            color: AppColors.border.withOpacity(0.6),
          ),

          const SizedBox(height: AppSpacing.sm),
          Text(
            interviewId,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyStrong,
        ),
      ],
    );
  }
}
