import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/progress_controller.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pc = Get.find<ProgressController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Progress')),
      body: Obx(() {
        final p = pc.progress.value;
        final weekly = p.weeklyXpLast7;
        final max = (weekly.isEmpty ? 1 : weekly.reduce((a,b)=>a>b?a:b)).toDouble();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Level progress
            Text('Level ${p.level} • ${p.xpInLevel}/${p.xpCapInLevel} XP',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: p.levelProgress.clamp(0, 1),
                minHeight: 14,
              ),
            ),
            const SizedBox(height: 20),

            // Weekly XP chart
            Text('Weekly XP', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(weekly.length, (i) {
                  final h = max==0 ? 0.0 : (weekly[i] / max) * 120.0;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Theme.of(context)
                                  .colorScheme.primary
                                  .withOpacity(.85),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(['M','T','W','T','F','S','S'][i],
                              style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 20),

            // Quick stats
            Text('Quick Stats', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12, runSpacing: 12,
              children: [
                _StatPill(label: 'Total XP', value: '${p.totalXp}'),
                _StatPill(label: 'Today', value: '+${p.todayEarnedXp} XP'),
                _StatPill(label: 'This Week', value: '+${p.weeklyEarnedXp} XP'),
                _StatPill(
                  label: 'Accuracy',
                  value: '${(p.questionStats.accuracy * 100).toStringAsFixed(0)}%',
                ),
                _StatPill(
                  label: 'Solved',
                  value: '${p.questionStats.correct}/${p.questionStats.total}',
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.labelLarge),
      ]),
    );
  }
}
