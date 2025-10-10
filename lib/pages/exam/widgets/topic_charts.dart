import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../controllers/exam_result_controller.dart';

class TopicCharts extends StatelessWidget {
  const TopicCharts({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ExamResultController>();
    final entries = c.topicRatios.entries.toList();
    final scheme = Theme.of(context).colorScheme;

    // 🔹 Eğer hiç veri yoksa basit bilgi mesajı göster
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            "No topic data available",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (ctx, i) {
          final entry = entries[i];
          final label = entry.key;
          final value = entry.value; // 0.0 - 1.0 arası double

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularPercentIndicator(
                radius: 50,
                lineWidth: 10,
                percent: value.clamp(0.0, 1.0),
                center: Text(
                  "${(value * 100).toInt()}%",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                progressColor: scheme.primary,
                backgroundColor: scheme.primary.withOpacity(0.2),
                circularStrokeCap: CircularStrokeCap.round,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          );
        },
      ),
    );
  }
}
