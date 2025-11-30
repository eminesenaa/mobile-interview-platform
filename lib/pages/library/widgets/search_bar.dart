// ===================== File: lib/pages/library/widgets/search_bar.dart =====================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../constants/colors.dart';
import '../../../constants/text_styles.dart';
import '../../../constants/constants.dart';
import '../controllers/library_controller.dart';
import 'collections_menu_sheet.dart';
import 'new_collection_dialog.dart';
import 'round_icon_button.dart';

class LibrarySearchBar extends StatelessWidget {
  const LibrarySearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<LibraryController>();

    return Obx(() {
      // TAB’A GÖRE HINT DİNAMİK
      final hint = {
        LibraryTab.all: 'Search Questions',
        LibraryTab.collections: 'Search Collections',
        LibraryTab.modules: 'Search Modules',
      }[c.currentTab.value]!;

      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: c.searchCtrl,
              onChanged: c.onSearchChanged,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.bodySmall,
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surfaceMuted,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.4),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _LibraryActionButtons(),
        ],
      );
    });
  }
}

/// 🔥 Tab’a göre dinamik aksiyon butonları
class _LibraryActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<LibraryController>();

    return Obx(() {
      final tab = c.currentTab.value;

      switch (tab) {
        case LibraryTab.all:
          final hasFilters = c.hasActiveFilters;

          return Row(
            children: [
              // FILTER BUTTON (Phosphor icon + renk değişimi)
              RoundIconButton(
                icon: PhosphorIcons.slidersHorizontal(),
                // Practice ile birebir aynı ikon!
                selected: c.hasActiveFilters,
                // renk değiştirme mantığı
                onTap: () => c.openFilterSheet(context),
              ),

              const SizedBox(width: AppSpacing.sm),

              // SELECT MULTI BUTTON (şimdilik normal)
              RoundIconButton(
                icon: PhosphorIcons.checkSquareOffset(),
                selected: c.isSelecting.value,
                onTap: () {
                  if (!c.isSelecting.value) {
                    c.startSelecting();
                  } else {
                    c.stopSelecting();
                  }
                },
              ),
            ],
          );

        case LibraryTab.collections:
          return Row(
            children: [
              // ➕ NEW COLLECTION
              RoundIconButton(
                icon: PhosphorIcons.plus(),
                onTap: () async {
                  final c = Get.find<LibraryController>();
                  final createdName = await Get.dialog<String?>(
                    NewCollectionDialog(),
                    barrierDismissible: true,
                  );

                  if (createdName == null || createdName.trim().isEmpty) return;

                  // Stream’in güncellenmesi için mini delay
                  await Future.delayed(const Duration(milliseconds: 350));

                  final match = c.lastRawCollections.firstWhereOrNull(
                    (x) =>
                        x.name.trim().toLowerCase() ==
                        createdName.trim().toLowerCase(),
                  );

                  if (match != null) {
                    c.autoSelectCollectionId.value = match.id;
                  }
                },
              ),

              const SizedBox(width: AppSpacing.sm),

              // ⋯ OVERFLOW MENU
              RoundIconButton(
                icon: PhosphorIcons.dotsThreeOutline(),
                selected: c.isSelectingCollections.value,
                onTap: () {
                  if (c.isSelectingCollections.value) {
                    c.stopCollectionSelecting();
                  } else {
                    _openCollectionsMenu(context);
                  }
                },
              ),
            ],
          );

        case LibraryTab.modules:
          return const SizedBox.shrink();
      }
    });
  }
  void _openCollectionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => const CollectionsMenuSheet(),
    );
  }

}
