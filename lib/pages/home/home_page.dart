// ===================== File: lib/pages/home/home_page.dart =====================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/constants/colors.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/constants/text_styles.dart';
import 'package:interview_project/pages/home/progress_page.dart';
import 'package:interview_project/controllers/progress_controller.dart';
import 'package:interview_project/pages/home/widgets/duel_entry_card.dart';
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
            // 🔥 TÜM SAYFAYA ORTAK HORIZONTAL PADDING
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ---- GREETING & STREAK ----
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: Obx(() {
                      final s = hc.streak.value;
                      if (s == null) return const SizedBox.shrink();

                      return StreakCard(
                        currentStreak: s.streakCount,
                        longestStreak: s.longestStreak,
                        history: s.streakHistory,
                      );
                    }),
                  ),

                  // ---- DUEL ENTRY ----
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: DuelEntryCard(
                      onTap: () {
                        // TODO: Navigate to Duel Type Selection Page
                      },
                    ),
                  ),

                  // ---- SECTION HEADER ----
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: Text(
                      "Today’s Popular Questions",
                      style: AppTextStyles.headline,
                    ),
                  ),

                  // ---- POPULAR QUESTIONS ----
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: Obx(() {
                      final items = hc.popularQuestions;
                      if (items.isEmpty) return const SizedBox.shrink();

                      return SizedBox(
                        height: 180,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.zero,
                          // 🔥 önemli
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

                  // ---- LEADERBOARD ----
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
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

                  const SizedBox(height: AppSpacing.lg),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
