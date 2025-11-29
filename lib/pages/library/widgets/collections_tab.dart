// ===================== File: lib/pages/library/widgets/collections_tab.dart =====================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../constants/constants.dart';
import '../collection_detail_page.dart';
import '../controllers/library_controller.dart';
import '../widgets/collection_card.dart';
import '../widgets/empty_state.dart';

class LibraryCollectionsTab extends StatelessWidget {
  const LibraryCollectionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<LibraryController>();

    return Obx(() {
      final query = c.searchQuery.value.trim().toLowerCase();

      return StreamBuilder(
        stream: c.collectionsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final all = snapshot.data!;
          // 🔎 Search filter
          final items = query.isEmpty
              ? all
              : all.where((col) =>
              col.name.toLowerCase().contains(query),
          ).toList();

          if (items.isEmpty) {
            return const LibraryEmptyState(
              title: 'No collections found',
              subtitle: 'Try searching for a different name.',
              icon: Icons.collections_bookmark_outlined,
            );
          }

          return GridView.custom(
            padding: const EdgeInsets.all(AppSpacing.md),
            physics: const BouncingScrollPhysics(),
            gridDelegate: SliverQuiltedGridDelegate(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              pattern: const [
                QuiltedGridTile(1, 1),
                QuiltedGridTile(1, 1),
                QuiltedGridTile(1, 2),
              ],
            ),
            childrenDelegate: SliverChildBuilderDelegate(
                  (context, i) {
                final col = items[i];
                return CollectionCard(
                  name: col.name,
                  count: col.count,
                  onTap: () => Get.to(
                        () => CollectionDetailPage(
                      collectionId: col.id,
                      collectionName: col.name,
                    ),
                  ),
                );
              },
              childCount: items.length,
            ),
          );
        },
      );
    });
  }
}
