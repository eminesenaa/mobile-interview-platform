import 'package:flutter/material.dart';
import '/../../../../constants/constants.dart';

class RdInterviewInfoCard extends StatelessWidget {
  final String position;
  final int totalCandidates;
  final String date;
  final String startTime;
  final String endTime;
  final String interviewId;

  const RdInterviewInfoCard({
    super.key,
    required this.position,
    required this.totalCandidates,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.interviewId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Text(
            "INTERVIEW INFO",
            style: AppTextStyles.label.copyWith(
              fontSize: 12
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          /// GRID 1 (POSITION - CANDIDATES)
          Row(
            children: [
              Expanded(
                child: _InfoColumn(
                  title: "POSITION",
                  value: position,
                ),
              ),
              Expanded(
                child: _InfoColumn(
                  title: "CANDIDATES",
                  value: "$totalCandidates total",
                  subtitle: "All reviewed",
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          /// GRID 2 (DATE - TIME)
          Row(
            children: [
              Expanded(
                child: _InfoColumn(
                  title: "DATE",
                  value: date,
                ),
              ),
              Expanded(
                child: _InfoColumn(
                  title: "TIME",
                  value: "$startTime – $endTime",
                  subtitle: "60 min",
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          /// 🔥 PREMIUM DIVIDER
          Container(
            height: 1,
            width: double.infinity,
            color: AppColors.border.withOpacity(0.4),
          ),

          const SizedBox(height: AppSpacing.sm),

          /// ID
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

class _InfoColumn extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;

  const _InfoColumn({
    required this.title,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // 🔥 kritik
      children: [
        Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyStrong,
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: AppTextStyles.bodySmall,
          ),
      ],
    );
  }
}
