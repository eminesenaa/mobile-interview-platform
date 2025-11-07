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
    final s = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: Obx(() {
        // ---- LOADING STATE ----
        if (c.loading.value) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 8,
            itemBuilder: (_, __) => Container(
              height: 56,
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.05),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }

        // ---- NO DATA FALLBACK ----
        if (c.entries.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No leaderboard data yet.'),
            ),
          );
        }

        // ---- MAIN VIEW ----
        return NotificationListener<ScrollNotification>(
          onNotification: (n) {
            // pagination placeholder (backend hazır olunca aktif edilir)
            return false;
          },
          child: ScrollConfiguration(
            behavior: const _NoGlowScrollBehavior(),
            child: CustomScrollView(
              key: const PageStorageKey('leaderboard_scroll'),
              physics: const ClampingScrollPhysics(),
              slivers: [
                // --- TOP 3 PODIUM ---
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
                        if (c.top3.isEmpty)
                          Container(
                            height: 80,
                            alignment: Alignment.center,
                            child: Text(
                              'No leaderboard data yet.',
                              style: t.bodyMedium?.copyWith(
                                  color: s.onSurfaceVariant),
                            ),
                          )
                        else
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
                                    color: s.primary.withOpacity(.08),
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
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Text('${e.xp} XP',
                                          style: t.labelSmall),
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

                // --- FULL LIST ---
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final e = c.entries[i];
                      final isMe = e.isMe ?? false;

                      return Container(
                        color: isMe
                            ? s.primary.withOpacity(.12)
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
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// disables glow/overscroll stretch
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
