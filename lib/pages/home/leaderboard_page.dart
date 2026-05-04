// ===================== File: leaderboard_page.dart =====================
// Purpose:
// Redesigned Leaderboard Page (UI Refactor)
//
// IMPORTANT:
// - Controller logic untouched
// - Uses new leaderboard widgets
// - Supports podium + segmented list structure
// ======================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/leaderboard_controller.dart';

import 'package:interview_project/constants/colors.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/constants/text_styles.dart';

// 🔥 NEW WIDGETS
import 'widgets/leaderboard/lb_podium.dart';
import 'widgets/leaderboard/lb_list_item.dart';
import 'widgets/leaderboard/lb_separator.dart';
import 'widgets/leaderboard/lb_me_item.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(LeaderboardController());

    return Scaffold(
      backgroundColor: AppColors.background,

      // ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        toolbarHeight: 70,
        centerTitle: true,
        title: Text(
          'Leaderboard',
          style: AppTextStyles.headline,
        ),
      ),

      // ================= BODY =================
      body: Obx(() {
        /// ================= LOADING =================
        if (c.loading.value) {
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: 6,
            itemBuilder: (_, __) => Container(
              height: 64,
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
          );
        }

        /// ================= EMPTY =================
        if (c.entries.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'No leaderboard data yet.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        /// ================= DATA SPLIT =================
        final entries = c.entries;

        final top3 = entries.length >= 3 ? entries.take(3).toList() : [];

        final others = entries.length > 3 ? entries.skip(3).toList() : [];

        final meIndex = others.indexWhere((e) => (e.isMe ?? false));

        final me =
            (meIndex != -1 && meIndex < others.length) ? others[meIndex] : null;

        final beforeMe = me != null && me.rank > 10
            ? entries.where((e) => e.rank >= 4 && e.rank <= 7).toList()
            : me != null
                ? entries.where((e) => e.rank >= 4 && e.rank < me.rank).toList()
                : entries.where((e) => e.rank >= 4 && e.rank <= 10).toList();

        final isLast = meIndex + 1 >= others.length;

        final afterMe = me != null && me.rank <= 10
            ? entries.where((e) => e.rank > me.rank && e.rank <= 10).toList()
            : me != null && !isLast
                ? [others[meIndex + 1]]
                : [];

        final beforeLastMe = me != null && isLast && meIndex > 0
            ? [others[meIndex - 1]]
            : <dynamic>[];

        /// ================= UI =================
        return NotificationListener<ScrollNotification>(
          onNotification: (_) => false,
          child: ScrollConfiguration(
            behavior: const _NoGlowScrollBehavior(),
            child: CustomScrollView(
              key: const PageStorageKey('leaderboard_scroll'),
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ================= PODIUM =================
                      if (top3.length == 3) LbPodium(top3: top3),

                      const SizedBox(height: AppSpacing.lg),

                      // ================= BEFORE ME =================
                      ...beforeMe.map((e) {
                        return Column(
                          children: [
                            LbListItem(user: e),
                            const SizedBox(height: 6),
                          ],
                        );
                      }),

                      // ================= SEPARATOR =================
                      if (me != null && me.rank > 10) const LbSeparator(),

                      // ================= BEFORE LAST ME =================
                      ...beforeLastMe.map((e) => Column(
                            children: [
                              LbListItem(user: e),
                              const SizedBox(height: 6),
                            ],
                          )),

                      // ================= ME =================
                      if (me != null) ...[
                        LbMeItem(me: me),
                        const SizedBox(height: 6),
                      ],

                      // ================= AFTER ME =================
                      ...afterMe.map((e) => Column(
                            children: [
                              LbListItem(user: e),
                              const SizedBox(height: 6),
                            ],
                          )),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ================= SCROLL FIX =================
class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
