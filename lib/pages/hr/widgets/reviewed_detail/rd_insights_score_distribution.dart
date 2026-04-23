import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

class RdInsightsScoreDistribution extends StatelessWidget {
  final Map<String, int> distribution;

  const RdInsightsScoreDistribution({
    super.key,
    required this.distribution,
  });

  @override
  Widget build(BuildContext context) {
    /// 🔥 MAX VALUE (normalize için)
    final max = distribution.values.isEmpty
        ? 1
        : distribution.values.reduce((a, b) => a > b ? a : b);

    /// 🎨 CUSTOM PALETTE
    final List<Color> palette = [
      AppColors.difficultyEasy,
      AppColors.difficultyEasyMedium,
      AppColors.difficultyMedium,
      AppColors.difficultyMediumHard,
      AppColors.difficultyHard,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: distribution.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final e = entry.value;

            /// 🔥 COLOR LOOP
            final color = palette[index % palette.length];

            final ratio = e.value / max;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  /// 🔥 LEFT LABEL (DAHA KOYU)
                  SizedBox(
                    width: 90,
                    child: Text(
                      e.key,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  /// 🔥 BAR
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 6,
                        color: color,
                        backgroundColor: AppColors.border.withOpacity(0.3),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  /// 🔥 VALUE (BAR RENGİYLE AYNI)
                  Text(
                    "${e.value}",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        )
      ],
    );
  }
}
