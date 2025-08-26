// lib/pages/library/library_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/library/widgets/collection_card.dart';

import '../../constants/colors.dart';          // pastelBlue
import '../../constants/text_styles.dart';
import '../../navigation/question_navigator.dart';
import '../../widgets/question_card.dart';
import 'controllers/library_controller.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LibraryController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: pastelBlue,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text('Library', style: AppTextStyles.headline),
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
                children: const [
                  _AllTab(),
                  _CollectionsTab(),
                  _ExamsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

        // 👇 burayı ekledik
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
          color: pastelBlue,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: AppTextStyles.headline.color ?? cs.onSurface,
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
              onChanged: c.onSearchChanged,           // ✅ controller'da mevcut
              decoration: InputDecoration(
                hintText: hint,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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

class _AllTab extends StatelessWidget {
  const _AllTab();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<LibraryController>();
    return Obx(() {
      final items = c.filteredQuestions;
      if (items.isEmpty) {
        return const _EmptyState(
          title: 'No saved questions',
          subtitle: 'Start saving questions to see them here.',
          icon: Icons.bookmark_border_rounded,
        );
      }
      return  ListView.separated(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final q = items[i];
          return QuestionCard(
            question: q,
            onTap: () => QuestionNavigator.open(q),
          );
        },
      );

    });
  }
}

class _DifficultyChip extends StatelessWidget {
  final String d;
  const _DifficultyChip({required this.d});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Text(d, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class _CollectionsTab extends StatelessWidget {
  const _CollectionsTab();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<LibraryController>();

    return Obx(() {
      final collections = c.filteredCollections; // rename ettiğin liste
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

        // 🔸 2 sütunlu; pattern: [1x1, 1x1, 1x2] tekrarı
        gridDelegate: SliverQuiltedGridDelegate(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,

          // 1 satır = 1 “row unit”; 1x2 = tam genişlik, 1x1 = yarım genişlik
          pattern: const [
            QuiltedGridTile(1, 1),
            QuiltedGridTile(1, 1),
            QuiltedGridTile(1, 2),
          ],
          // repeatPattern: QuiltedGridRepeatPattern.inverted, // istersen invert dene
        ),

        childrenDelegate: SliverChildBuilderDelegate(
              (context, i) {
            final col = collections[i];
            return CollectionCard(
              name: col.name,
              count: col.count,
              onTap: () => c.onCollectionTap(col.id),
              // onLongPress: () => c.showCollectionMenu(col.id), // (istersen)
            );
          },
          childCount: collections.length,
        ),
      );
    });
  }
}


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
