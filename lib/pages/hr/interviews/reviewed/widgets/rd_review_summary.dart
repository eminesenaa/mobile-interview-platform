import 'package:flutter/material.dart';
import '/../../../../constants/constants.dart';
import 'rd_summary_stat.dart';
import 'rd_acceptance_bar.dart';

class RdReviewSummary extends StatelessWidget {
  final int total;
  final int accepted;
  final int rejected;

  const RdReviewSummary({
    super.key,
    required this.total,
    required this.accepted,
    required this.rejected,
  });

  @override
  Widget build(BuildContext context) {
    final rate = total == 0 ? 0 : ((accepted / total) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "REVIEW SUMMARY",
          style: AppTextStyles.label.copyWith(fontSize: 12),
        ),

        const SizedBox(height: AppSpacing.md),

        /// 🔥 GRID FIX
        Row(
          children: [
            Expanded(
              child: RdSummaryStat(
                label: "Total",
                value: "$total",
              ),
            ),
            const SizedBox(width: 8),

            Expanded(
              child: RdSummaryStat(
                label: "Accepted",
                value: "$accepted",
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 8),

            Expanded(
              child: RdSummaryStat(
                label: "Rejected",
                value: "$rejected",
                color: AppColors.error,
              ),
            ),
            const SizedBox(width: 8),

            Expanded(
              child: RdSummaryStat(
                label: "Rate",
                value: "$rate%",
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        RdAcceptanceBar(
          accepted: accepted,
          rejected: rejected,
        ),
      ],
    );
  }
}