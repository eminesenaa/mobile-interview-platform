// ===================== File: lib/pages/home/home_page.dart =====================
// Purpose:
// Refactored Home Page with new UI architecture
//
// IMPORTANT:
// - Logic untouched (HomeController 그대로)
// - Only UI layer updated
// - Uses new Home widgets (sections)
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:interview_project/constants/colors.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/constants/text_styles.dart';
import 'package:interview_project/pages/home/widgets/home/hp_duel_section.dart';
import 'package:interview_project/pages/home/widgets/home/hp_leaderboard_section.dart';
import 'package:interview_project/pages/home/widgets/home/hp_section_header.dart';
import 'package:interview_project/pages/home/widgets/home/hp_streak_section.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'controllers/home_controller.dart';
import '../duello/duel_type_page.dart';
import 'leaderboard_page.dart';

// 🔥 EXISTING (KEEP)
import 'widgets/home/hp_user_greeting_title.dart';
import 'widgets/home/hp_popular_question_card.dart';

// 🔥 NEW UI LAYER

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hc = Get.put(HomeController());

    return Scaffold(
      backgroundColor: AppColors.background,

      // ===================== APP BAR =====================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        toolbarHeight: 70,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Row(
            children: [
              Expanded(child: UserGreetingTitle()),

              // NOTIFICATION ICON
              Icon(
                PhosphorIcons.bell(),
                size: 22,
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: AppColors.border,
          ),
        ),
      ),

      // ===================== BODY =====================
      body: RefreshIndicator(
        onRefresh: hc.refreshAll,
        child: CustomScrollView(
          key: const PageStorageKey('home_scroll'),
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 0,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ===================== STREAK =====================
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                    child: Obx(() {
                      final s = hc.streak.value;
                      if (s == null) return const SizedBox.shrink();

                      return HpStreakSection(
                        current: s.streakCount,
                        longest: s.longestStreak,

                        // 🔥 TYPE SAFE
                        history: Map<String, bool>.from(s.streakHistory),
                      );
                    }),
                  ),

                  // ===================== DUEL =====================
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: HpDuelSection(
                      onTap: () {
                        Get.to(
                          () => const DuelTypePage(),
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 300),
                        );
                      },
                    ),
                  ),

                  // ===================== POPULAR HEADER =====================
                  const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: HpSectionHeader(
                      title: "Today’s Popular Questions",
                    ),
                  ),

                  // ===================== POPULAR LIST =====================
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: Obx(() {
                      final items = hc.popularQuestions;
                      if (items.isEmpty) return const SizedBox.shrink();

                      return SizedBox(
                        height: 180,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) {
                            return PopularQuestionCard.horizontal(
                              question: items[i],
                              width: MediaQuery.of(context).size.width * 0.8,
                            );
                          },
                        ),
                      );
                    }),
                  ),

                  // ===================== LEADERBOARD =====================
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: Obx(() {
                      return HpLeaderboardSection(
                        top3: hc.top3,
                        me: hc.me.value,
                        onTap: () {
                          Get.to(() => const LeaderboardPage());
                        },
                      );
                    }),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
