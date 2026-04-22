import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

class RdInsightsDecisionBreakdown extends StatelessWidget {
  final int accepted;
  final int rejected;

  const RdInsightsDecisionBreakdown({
    super.key,
    required this.accepted,
    required this.rejected,
  });

  @override
  Widget build(BuildContext context) {
    final total = accepted + rejected;
    final percent = total == 0 ? 0.0 : accepted / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("DECISION BREAKDOWN",
            style: AppTextStyles.label.copyWith(fontSize: 12)),
        const SizedBox(height: AppSpacing.md),

        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 10,
                  backgroundColor: AppColors.error.withOpacity(0.2),
                  valueColor:
                  AlwaysStoppedAnimation(AppColors.success),
                ),
              ),
              Column(
                children: [
                  Text("${(percent * 100).round()}%",
                      style: AppTextStyles.headline),
                  Text("accepted", style: AppTextStyles.bodySmall),
                ],
              )
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legend(AppColors.success, "Accepted — $accepted"),
            const SizedBox(width: 12),
            _legend(AppColors.error, "Rejected — $rejected"),
          ],
        )
      ],
    );
  }

  Widget _legend(Color color, String text) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(
            color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: AppTextStyles.bodySmall),
      ],
    );
  }
}