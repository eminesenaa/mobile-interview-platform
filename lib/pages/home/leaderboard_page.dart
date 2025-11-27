// lib/pages/home/leaderboard_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/leaderboard_controller.dart';
import 'widgets/leaderboard_list_item.dart';
import 'package:interview_project/constants/colors.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/constants/text_styles.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(LeaderboardController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        toolbarHeight: 70,
        // HomePage ile aynı yükseklik
        centerTitle: true,
        // 💙 Bu sayfada da global davranışı takip etsin
        title: Text(
          'Leaderboard',
          style: AppTextStyles.headline,
        ),
      ),
      body: Obx(() {
        if (c.loading.value) {
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: 8,
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

        return NotificationListener<ScrollNotification>(
          onNotification: (_) => false,
          child: ScrollConfiguration(
            behavior: const _NoGlowScrollBehavior(),
            child: CustomScrollView(
              key: const PageStorageKey('leaderboard_scroll'),
              physics: const ClampingScrollPhysics(),
              slivers: [
                // ===== FULL LIST =====
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final e = c.entries[i];
                      final isMe = e.isMe ?? false;

                      return Container(
                        color: isMe
                            ? AppColors.primary.withOpacity(0.03)
                            : Colors.transparent,
                        child: Column(
                          children: [
                            LeaderboardListItem(e: e),
                            const SizedBox(height: 6),
                          ],
                        ),
                      );
                    },
                    childCount: c.entries.length,
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
