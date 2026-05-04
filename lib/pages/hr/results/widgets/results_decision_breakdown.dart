import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

class ResultsDecisionBreakdown extends StatelessWidget {
  final int accepted;
  final int rejected;

  const ResultsDecisionBreakdown({
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
        /// 🔥 CENTERED DONUT
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 10, // 🔥 daha kalın
                  backgroundColor: AppColors.error.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation(AppColors.success),
                ),
              ),

              /// 🔥 TEXT ORTA
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${(percent * 100).round()}%",
                    style: AppTextStyles.headline, // 🔥 büyük text
                  ),
                  Text(
                    "accepted",
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        /// 🔥 LEGEND
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legend(AppColors.success, "Accepted — $accepted"),
            const SizedBox(width: 16),
            _legend(AppColors.error, "Rejected — $rejected"),
          ],
        ),
      ],
    );
  }

  Widget _legend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
