import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../constants/colors.dart';
import '../../controllers/exam_result_controller.dart';

class TopicCharts extends StatelessWidget {
  const TopicCharts({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ExamResultController>();
    final entries = c.topicRatios.entries.toList();

    // 🔹 Eğer hiç veri yoksa
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No topic data available',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    /// 🎨 Soft, tekrar edebilir renk paleti
    final List<Color> palette = [
      AppColors.topicDeepTwilight,
      AppColors.topicBrightTeal,
      AppColors.topicTurquoise,
      AppColors.topicFrostedBlue,
      AppColors.topicLightCyan,
    ];

    /// 🏷️ Label düzenleyici
    String formatLabel(String raw) {
      final cleaned = raw.replaceAll(RegExp(r'[_\-]+'), ' ').trim();
      if (cleaned.isEmpty) return '';

      // 🔥 Special case
      if (cleaned.toLowerCase() == 'sql') return 'SQL';

      return cleaned
          .split(RegExp(r'\s+'))
          .map((w) => w.isEmpty
              ? w
              : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
          .join(' ');
    }

    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (ctx, i) {
          final entry = entries[i];
          final value = entry.value.clamp(0.0, 1.0);
          final color = palette[i % palette.length];

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularPercentIndicator(
                radius: 48,
                lineWidth: 9,
                percent: value,
                animation: true,
                animateFromLastPercent: true,
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: color,
                backgroundColor: color.withValues(alpha: 0.18),
                center: Text(
                  '${(value * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                formatLabel(entry.key),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
