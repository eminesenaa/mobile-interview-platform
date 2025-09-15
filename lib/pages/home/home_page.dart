// ===================== File: lib/pages/home/home_page.dart =====================
// Purpose: Home sayfası. Streak kartı, Today’s Popular Questions (yatay scroll)
//          ve Your Progress bölümlerini içerir.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/home/progress_page.dart';
import 'package:interview_project/controllers/progress_controller.dart';
import 'package:interview_project/pages/home/widgets/progress_summary_card.dart';
import 'controllers/home_controller.dart';
import 'widgets/streak_card.dart';
import 'widgets/popular_question_card.dart';
import 'widgets/user_greeting_title.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hc = Get.put(HomeController());

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const UserGreetingTitle(),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: hc.refreshAll,
        child: CustomScrollView(
          slivers: [
            // ---- GREETING & STREAK ----
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StreakCard.preview(),
                  ],
                ),
              ),
            ),

            // ---- SECTION HEADER: TODAY’S POPULAR QUESTIONS ----
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text(
                  "Today’s Popular Questions",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),

            // ---- HORIZONTAL POPULAR QUESTIONS ----
            SliverToBoxAdapter(
              child: Obx(() {
                final items = hc.popularQuestions;
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        "No questions available today",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    primary: false,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => PopularQuestionCard.horizontal(
                      question: items[i],
                      // 🔹 genişliği biraz küçült ki scroll bariz olsun
                      width: MediaQuery.of(context).size.width * 0.7,
                    ),
                  ),
                );
              }),
            ),

            // ---- YOUR PROGRESS ----
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Your Progress',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Get.to(() => const ProgressPage()),
                          child: const Text('See all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // --- HORIZONTAL 3 SUMMARY CARDS ---
                    Obx(() {
                      final pc = hc.pc;
                      final p = pc.progress.value;
                      final acc =
                          (p.questionStats.accuracy * 100).toStringAsFixed(0);

                      final cards = [
                        ProgressSummaryCard(
                          icon: Icons.workspace_premium_rounded,
                          title: 'Level ${p.level}',
                          value: '${pc.totalXp.value} XP',
                          caption:
                              'to next: ${p.xpCapInLevel - p.xpInLevel} XP',
                          onTap: () => Get.to(() => const ProgressPage()),
                        ),
                        ProgressSummaryCard(
                          icon: Icons.check_circle_rounded,
                          title: 'Accuracy',
                          value: '$acc%',
                          caption:
                              '${p.questionStats.correct}/${p.questionStats.total} correct',
                          onTap: () => Get.to(() => const ProgressPage()),
                        ),
                        ProgressSummaryCard(
                          icon: Icons.bolt_rounded,
                          title: 'Today',
                          value: '+${p.todayEarnedXp} XP',
                          caption: 'This week: +${p.weeklyEarnedXp} XP',
                          onTap: () => Get.to(() => const ProgressPage()),
                        ),
                      ];

                      return Column(
                        children: [
                          SizedBox(
                            height: 130,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: true,
                              primary: false,
                              itemBuilder: (_, i) => cards[i],
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemCount: cards.length,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _MiniBarChart(values: p.weeklyXpLast7),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== helper widgets =====
class _MiniBarChart extends StatelessWidget {
  final List<int> values;
  const _MiniBarChart({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    final max = (values.isEmpty ? 1 : values.reduce((a, b) => a > b ? a : b))
        .toDouble();

    return Container(
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
        children: List.generate(values.length, (i) {
          final h = max == 0 ? 0.0 : (values[i] / max) * 90.0;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(.85),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
