// ===================== File: lib/pages/home/leaderboard_page.dart =====================
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/leaderboard_controller.dart';
import 'widgets/leaderboard_list_item.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(LeaderboardController());
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: Obx(() {
        if (c.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (n) {
            // TODO: pagination — backend hazır olunca aç
            // if (n.metrics.pixels >= n.metrics.maxScrollExtent - 64) {
            //   c.fetchMore();
            // }
            return false;
          },
          child: ScrollConfiguration(
            behavior: const _NoGlowScrollBehavior(),
            child: CustomScrollView(
              key: const PageStorageKey('leaderboard_scroll'),
              physics: const ClampingScrollPhysics(), // üstte esneme yok
              slivers: [
                // --- Top 3 mini podium ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Top 3',
                          style: t.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: List.generate(c.top3.length, (i) {
                            final e = c.top3[i];
                            return Expanded(
                              child: Container(
                                margin:
                                const EdgeInsets.symmetric(horizontal: 4),
                                padding:
                                const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(.08),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      child: Text(e.initials),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '#${e.rank}',
                                      style: t.labelMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text('${e.xp} XP', style: t.labelSmall),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- Full list ---
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                      final item = LeaderboardListItem(e: c.entries[i]);
                      return Column(
                        children: [
                          item,
                          const SizedBox(height: 6), // küçük ayraç
                        ],
                      );
                    },
                    childCount: c.entries.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
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
    // overscroll glow ve stretch'i kapatır
    return child;
  }
}
