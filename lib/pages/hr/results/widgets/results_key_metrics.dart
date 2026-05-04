import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../constants/constants.dart';

class ResultsKeyMetrics extends StatelessWidget {
  final double avgScore;
  final double acceptRate;
  final int highest;
  final int lowest;

  const ResultsKeyMetrics({
    super.key,
    required this.avgScore,
    required this.acceptRate,
    required this.highest,
    required this.lowest,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _card("Avg Score", "${avgScore.toStringAsFixed(0)}",
                    PhosphorIcons.chartLine(PhosphorIconsStyle.bold), AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(
                child: _card("Accept Rate", "${acceptRate.toStringAsFixed(0)}%",
                    PhosphorIcons.checkCircle(PhosphorIconsStyle.bold), AppColors.success)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _card("Highest", "$highest", PhosphorIcons.arrowUp(PhosphorIconsStyle.bold),
                    AppColors.success)),
            const SizedBox(width: 12),
            Expanded(
                child: _card("Lowest", "$lowest", PhosphorIcons.arrowDown(PhosphorIconsStyle.bold),
                    AppColors.error)),
          ],
        ),
      ],
    );
  }

  Widget _card(String label, String value, IconData icon, Color color) {
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
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.title),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
