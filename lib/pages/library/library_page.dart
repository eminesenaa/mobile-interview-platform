// ===================== File: lib/pages/library/library_page.dart =====================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../widgets/question_card.dart';
import '../practice/controllers/practice_controller.dart';
import '../runner/question_feed.dart';
import '../runner/question_runner_page.dart';
import 'widgets/collection_card.dart';
import 'collection_detail_page.dart';
import 'controllers/library_controller.dart';
import '../../models/question.dart';
import 'services/library_service.dart';
import 'widgets/save_question_to_collection_sheet.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});
  static final _controller = Get.put(LibraryController());

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LibraryController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: const Text('My Library'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Sort / Filter',
            icon: const Icon(Icons.swap_vert_rounded),
            onPressed: controller.onSortPressed,
          ),
          IconButton(
            tooltip: 'New Collection',
            icon: const Icon(Icons.add_rounded),
            onPressed: controller.onCreateCollectionPressed,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // SEGMENTED TAB
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: _SegmentedTabBar(controller: controller.tabController),
            ),
            // SEARCH
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _SearchBar(),
            ),
            // CONTENT
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  _AllTab(openRunner: _openRunner),
                  _CollectionsTab(openRunner: _openRunner),
                  const _ExamsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openRunner(
      List<Question> questions,
      int startIndex, {
        required QuestionSourceKind kind,
        String? label,
        String? refId, // collectionId vs.
      }) {
    final feed = QuestionFeed(
      questionIds: questions.map((q) => q.id).toList(), // id çıkarma metodun farklıysa uyarlayabilirsin
      questions: questions, // hazır liste varsa veriyoruz
      startIndex: startIndex,
      source: QuestionSourceContext(
        kind: kind,
        label: label,
        refId: refId,
      ),
    );

    Get.to(() => QuestionRunnerPage(feed: feed));
  }
}


class _SegmentedTabBar extends StatelessWidget {
  final TabController controller;
  const _SegmentedTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTextStyles.headline.color ?? cs.primary,
          width: 1.5,
        ),
      ),
      child: TabBar(
        controller: controller,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelPadding: const EdgeInsets.symmetric(vertical: 8),
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: AppColors.textPrimary ?? cs.onSurface,
        unselectedLabelColor: cs.onSurfaceVariant,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Collections'),
          Tab(text: 'Exams'),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<LibraryController>();
    return Obx(() {
      final hint = switch (c.currentTab.value) {
        LibraryTab.all => 'Search Questions',
        LibraryTab.collections => 'Search Collections',
        LibraryTab.exams => 'Search Exams',
      };

      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: c.searchCtrl,
              onChanged: c.onSearchChanged,
              decoration: InputDecoration(
                hintText: hint,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _RoundIconButton(
            icon: Icons.swap_vert_rounded,
            onTap: c.onSortPressed,
          ),
          const SizedBox(width: 8),
          _RoundIconButton(
            icon: Icons.add_rounded,
            onTap: c.onCreateCollectionPressed,
          ),
        ],
      );
    });
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

typedef OpenRunner = void Function(
    List<Question> questions,
    int startIndex, {
    required QuestionSourceKind kind,
    String? label,
    String? refId,
    });


// ===================== ALL TAB =====================
class _AllTab extends StatelessWidget {
  final OpenRunner openRunner;
  const _AllTab({required this.openRunner});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<LibraryController>();
    return StreamBuilder<List<Question>>(
      stream: c.savedQuestionsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data!;
        if (items.isEmpty) {
          return const _EmptyState(
            title: 'No saved questions',
            subtitle: 'Start saving questions to see them here.',
            icon: Icons.bookmark_border_rounded,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final q = items[i];
            return QuestionCard(
              question: q,
              isSaved: true,
              onTap: () => openRunner(
                items,
                i,
                kind: QuestionSourceKind.libraryAll,
                label: 'Library • All',
              ),
              onSaveTap: () async {
                await showModalBottomSheet(
                  context: context,
                  builder: (_) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading:
                              const Icon(Icons.delete_outline, color: Colors.red),
                          title: const Text("Remove from Library"),
                          onTap: () async {
                            Navigator.pop(context);
                            await LibraryService.instance
                                .removeQuestionEverywhere(q.id);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.folder_outlined,
                              color: Colors.blue),
                          title: const Text("Move to Collection"),
                          onTap: () async {
                            Navigator.pop(context);
                            await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) =>
                                  SaveQuestionToCollectionSheet(questionId: q.id),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// ===================== COLLECTIONS TAB =====================
class _CollectionsTab extends StatelessWidget {
  final OpenRunner openRunner;
  const _CollectionsTab({required this.openRunner});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<LibraryController>();
    return StreamBuilder(
      stream: c.collectionsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final collections = snapshot.data!;
        if (collections.isEmpty) {
          return const _EmptyState(
            title: 'No collections yet',
            subtitle: 'Create your first collection to group saved questions.',
            icon: Icons.collections_bookmark_outlined,
          );
        }
        return GridView.custom(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverQuiltedGridDelegate(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            pattern: const [
              QuiltedGridTile(1, 1),
              QuiltedGridTile(1, 1),
              QuiltedGridTile(1, 2),
            ],
          ),
          childrenDelegate: SliverChildBuilderDelegate(
            (context, i) {
              final col = collections[i];
              return CollectionCard(
                name: col.name,
                count: col.count,
                onTap: () =>
                    Get.to(() => CollectionDetailPage(
                        collectionId: col.id,
                      collectionName: col.name,
                      openRunner: openRunner,
                    )
                    ),
              );
            },
            childCount: collections.length,
          ),
        );
      },
    );
  }
}

// ===================== EXAMS TAB =====================
class _ExamsTab extends StatelessWidget {
  const _ExamsTab();

  @override
  Widget build(BuildContext context) {
    return const _EmptyState(
      title: 'Exams (soon)',
      subtitle: 'You will be able to save full mock exams here.',
      icon: Icons.timer_outlined,
    );
  }
}

// ===================== EMPTY STATE =====================
class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(subtitle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
