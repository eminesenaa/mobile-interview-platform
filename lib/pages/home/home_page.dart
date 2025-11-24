// ===================== File: lib/pages/home/home_page.dart =====================
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/constants/colors.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/constants/text_styles.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        toolbarHeight: 70,
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(child: UserGreetingTitle()),
            ],
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppColors.border),
        ),
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
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,  // left
                  AppSpacing.lg,  // top
                  AppSpacing.md,  // right
                  AppSpacing.lg,  // bottom → alttaki section ile 24px
                ),
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
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,               // üst boşluk sıfır → yukarıdaki Streak bottom=lg zaten verdi
                  AppSpacing.md,
                  AppSpacing.sm,   // başlık ile kartlar arası 8px
                ),
                child: Text(
                  "Today’s Popular Questions",
                  style: AppTextStyles.headline,
                ),
              ),
            ),

            // ---- HORIZONTAL POPULAR QUESTIONS ----
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: AppSpacing.lg, // Popular list ↔ Leaderboard arası 24px
                ),
                child: Obx(() {
                  final items = hc.popularQuestions;
                  if (items.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      primary: false,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(width: 12),
                      itemBuilder: (_, i) => PopularQuestionCard.horizontal(
                        question: items[i],
                        width: MediaQuery.of(context).size.width * 0.8,
                      ),
                    ),
                  );
                }),
              ),
            ),

            // ---- LEADERBOARD CARD ----
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,              // üst boşluk yok; yukarıdaki list bottom=lg veriyor
                  AppSpacing.md,
                  0,
                ),
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
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.lg), // Leaderboard ↔ Progress arası 24px
            ),

            // ---- YOUR PROGRESS ----
            // SliverToBoxAdapter(
            //   child: Padding(
            //     padding: const EdgeInsets.fromLTRB(
            //       AppSpacing.md,
            //       AppSpacing.lg,
            //       AppSpacing.md,
            //       AppSpacing.lg,
            //     ),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Row(
            //           children: [
            //             Text(
            //               'Your Progress',
            //               style: AppTextStyles.headline,
            //             ),
            //             const Spacer(),
            //             TextButton(
            //               onPressed: () {
            //                 Get.to(() => const ProgressPage());
            //               },
            //               child: const Text('See all'),
            //             ),
            //           ],
            //         ),
            //         const SizedBox(height: 12),
            //
            //         // --- SUMMARY CARDS ---
            //         Obx(() {
            //           final pc = hc.pc;
            //           final p = pc.progress.value;
            //           final acc =
            //               (p.questionStats.accuracy * 100).toStringAsFixed(0);
            //
            //           final cards = [
            //             ProgressSummaryCard(
            //               icon: Icons.workspace_premium_rounded,
            //               title: 'Level ${p.level}',
            //               value: '${pc.totalXp.value} XP',
            //               caption:
            //                   'to next: ${p.xpCapInLevel - p.xpInLevel} XP',
            //               onTap: () => Get.to(() => const ProgressPage()),
            //             ),
            //             ProgressSummaryCard(
            //               icon: Icons.check_circle_rounded,
            //               title: 'Accuracy',
            //               value: '$acc%',
            //               caption:
            //                   '${p.questionStats.correct}/${p.questionStats.total} correct',
            //               onTap: () => Get.to(() => const ProgressPage()),
            //             ),
            //             ProgressSummaryCard(
            //               icon: Icons.bolt_rounded,
            //               title: 'Today',
            //               value: '+${p.todayEarnedXp} XP',
            //               caption: 'This week: +${p.weeklyEarnedXp} XP',
            //               onTap: () => Get.to(() => const ProgressPage()),
            //             ),
            //           ];
            //
            //           return Column(
            //             children: [
            //               Row(
            //                 children: [
            //                   Expanded(child: cards[0]),
            //                   const SizedBox(width: 12),
            //                   Expanded(child: cards[1]),
            //                 ],
            //               ),
            //               const SizedBox(height: 12),
            //               Row(
            //                 children: [
            //                   Expanded(child: cards[2]),
            //                 ],
            //               ),
            //             ],
            //           );
            //         }),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
