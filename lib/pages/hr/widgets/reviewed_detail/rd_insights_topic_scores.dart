import 'package:flutter/material.dart';
import '../../../../constants/constants.dart';

class RdInsightsTopicScores extends StatelessWidget {
  final Map<String, int> topics;

  const RdInsightsTopicScores({
    super.key,
    required this.topics,
  });

  @override
  Widget build(BuildContext context) {
    /// 🎨 CUSTOM COLOR PALETTE (BURAYI SEN DOLDURACAKSIN)
    final List<Color> palette = [
      AppColors.cinnabar,
      AppColors.accentRoyalPlum,
      AppColors.stormyTeal,
      AppColors.accentCeladon,
      AppColors.honeyBronze,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "AVG SCORE BY TOPIC",
          style: AppTextStyles.label.copyWith(fontSize: 12),
        ),
        const SizedBox(height: AppSpacing.md),
        Column(
          children: topics.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final e = entry.value;

            /// 🔥 COLOR LOOP (5 renk → tekrar başa döner)
            final color = palette[index % palette.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  /// 🔥 TOPIC NAME (DAHA KOYU)
                  SizedBox(
                    width: 100,
                    child: Text(
                      _format(e.key),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary, // 🔥 koyu yaptık
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  /// 🔥 PROGRESS BAR
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: e.value / 100,
                        minHeight: 6,
                        color: color,
                        backgroundColor: AppColors.border.withOpacity(0.3),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  /// 🔥 PERCENT
                  Text(
                    "${e.value}%",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _format(String raw) {
    return raw.replaceAll("_", " ").toUpperCase();
  }
}
