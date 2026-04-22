import 'package:flutter/material.dart';
import 'package:interview_project/pages/hr/widgets/reviewed_detail/rd_metric_card.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../constants/constants.dart';

class RdInsightsKeyMetrics extends StatelessWidget {
  final double avgScore;
  final double acceptRate;
  final int highest;
  final int lowest;

  const RdInsightsKeyMetrics({
    super.key,
    required this.avgScore,
    required this.acceptRate,
    required this.highest,
    required this.lowest,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("KEY METRICS", style: AppTextStyles.label.copyWith(fontSize: 12)),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            RdMetricCard(
              label: "Avg Score",
              value: avgScore.toStringAsFixed(1),
              icon: PhosphorIcons.chartLineUp(PhosphorIconsStyle.bold),
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
            RdMetricCard(
              label: "Accept Rate",
              value: "${acceptRate.toStringAsFixed(1)}%",
              icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.bold),
              color: AppColors.success,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            RdMetricCard(
              label: "Highest Score",
              value: "$highest",
              icon: PhosphorIcons.arrowUp(PhosphorIconsStyle.bold),
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
            RdMetricCard(
              label: "Lowest Score",
              value: "$lowest",
              icon: PhosphorIcons.arrowDown(PhosphorIconsStyle.bold),
              color: AppColors.error,
            ),
          ],
        ),
      ],
    );
  }
}
