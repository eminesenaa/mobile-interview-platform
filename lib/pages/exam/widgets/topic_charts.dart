import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class TopicCharts extends StatelessWidget {
  final Map<String, double> topicPercents;
  // örn: {"Java": 0.75, "DSA": 0.5}

  const TopicCharts({super.key, required this.topicPercents});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: topicPercents.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (ctx, i) {
          final entry = topicPercents.entries.elementAt(i);
          final label = entry.key;
          final value = entry.value; // 0.0 - 1.0 arası

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
