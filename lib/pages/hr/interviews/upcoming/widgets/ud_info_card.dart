import 'package:flutter/material.dart';
import '/../../../../constants/constants.dart';

class UpcomingInfoCard extends StatelessWidget {
  final String position;
  final String team;
  final String candidateInfo;
  final String candidateSub;
  final String date;
  final String day;
  final String timeRange;
  final String duration;
  final String interviewId;

  const UpcomingInfoCard({
    super.key,
    required this.position,
    required this.team,
    required this.candidateInfo,
    required this.candidateSub,
    required this.date,
    required this.day,
    required this.timeRange,
    required this.duration,
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
          // ================= ROW 1 =================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Item(
                  "POSITION",
                  position,
                  sub: team,
                ),
              ),
              Expanded(
                child: _Item(
                  "CANDIDATES",
                  candidateInfo,
                  sub: candidateSub,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ================= ROW 2 =================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Item(
                  "DATE",
                  date,
                  sub: day,
                ),
              ),
              Expanded(
                child: _Item(
                  "TIME",
                  timeRange,
                  sub: duration,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ================= DIVIDER =================
          Container(
            height: 1,
            width: double.infinity,
            color: AppColors.border.withOpacity(0.6),
          ),

          const SizedBox(height: AppSpacing.sm),

          // ================= ID =================
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

class _Item extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;

  const _Item(this.label, this.value, {this.sub});

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
        Text(value, style: AppTextStyles.bodyStrong),
        if (sub != null)
          Text(
            sub!,
            style: AppTextStyles.bodySmall,
          ),
      ],
    );
  }
}
