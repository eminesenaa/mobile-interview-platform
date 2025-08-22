// ===================== File: lib/pages/home/home_page.dart =====================
// Purpose: Home sayfası. Streak kartı, Today’s Popular Questions (yatay scroll)
//          ve Your Progress bölümlerini içerir.
// Notes:
// - User verisi yokken greeting statik, ileride UserController’dan alınacak.
// - ProgressController bağlandı (XP, level, weekly bar chart).
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/home/progress_page.dart';
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

    // TODO: İleride UserController’dan çekilecek
    // final user = Get.find<UserController>().currentUser.value;
    // final name = user?.name ?? 'there';
    // final photo = user?.photoUrl;
    const name = 'Rümeysa';
    const String? photo = null;


    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const UserGreetingTitle(
          name: name,
          photoUrl: photo,
          // onAvatarTap: () => Get.to(() => const ProfilePage()),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.notifications_none),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: hc.refreshAll,
        child: CustomScrollView(
          slivers: [
            // ---- GREETING & STREAK ----
            const SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StreakCard.preview(),
                  ],
                ),
              ),
            ),

            // ---- SECTION HEADER: TODAY’S POPULAR QUESTIONS ----
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Today’s Popular Questions",
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
            ),

            // ---- HORIZONTAL POPULAR QUESTIONS ----
            SliverToBoxAdapter(
              child: Obx(() {
                final items = hc.popularQuestions;
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("No questions available"),
                  );
                }
                return SizedBox(
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => PopularQuestionCard.horizontal(
                      question: items[i],
                      width: MediaQuery.of(_).size.width * 0.78,
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
                        Text('Your Progress',
                            style: Theme.of(context).textTheme.titleMedium),
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
                      final pc = Get.find<HomeController>().pc;
                      final p = pc.progress.value;
                      final acc = (p.questionStats.accuracy * 100).toStringAsFixed(0);

                      final cards = [
                        ProgressSummaryCard(
                          icon: Icons.check_circle_rounded,
                          title: 'Accuracy',
                          value: '$acc%',
                          caption: '${p.questionStats.correct}/${p.questionStats.total} correct',
                          onTap: () => Get.to(() => const ProgressPage()),
                        ),
                        ProgressSummaryCard(
                          icon: Icons.workspace_premium_rounded,
                          title: 'Level ${p.level}',
                          value: '${p.xpInLevel}/${p.xpCapInLevel} XP',
                          caption: 'to next: ${p.xpCapInLevel - p.xpInLevel} XP',
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

                      return SizedBox(
                        height: 130,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          itemBuilder: (_, i) => cards[i],
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemCount: cards.length,
                        ),
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
    final max = (values.isEmpty
        ? 1
        : values.reduce((a, b) => a > b ? a : b))
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
