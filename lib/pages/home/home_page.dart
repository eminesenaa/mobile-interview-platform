// ===================== File: lib/pages/home/home_page.dart =====================
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/home/progress_page.dart';
import 'package:interview_project/controllers/progress_controller.dart';
import 'package:interview_project/pages/home/widgets/leaderboard_card.dart';
import 'package:interview_project/pages/home/widgets/progress_summary_card.dart';
import 'controllers/home_controller.dart';
import 'leaderboard_page.dart';
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
          key: const PageStorageKey('home_scroll'),
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ---- GREETING & STREAK ----
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      final s = hc.streak.value;
                      if (s == null) {
                        return const StreakCard.preview();
                      }
                      return StreakCard(
                        currentStreak: s.streakCount,
                        longestStreak: s.longestStreak,
                        history: s.streakHistory,
                      );
                    }),
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
                      width: MediaQuery.of(context).size.width * 0.7,
                    ),
                  ),
                );
              }),
            ),

            // ---- LEADERBOARD CARD ----
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Obx(
                  () => LeaderboardCard(
                    top3: hc.top3,
                    me: hc.me.value,
                    loading: hc.lbLoading.value,
                    onTap: () {
                      Get.to(() => const LeaderboardPage());
                    },
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

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

                    // --- SUMMARY CARDS ---
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
