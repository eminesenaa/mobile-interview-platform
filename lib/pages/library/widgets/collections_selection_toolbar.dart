// ===================== File: lib/pages/library/widgets/collections_selection_toolbar.dart =====================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../constants/text_styles.dart';
import '../controllers/library_controller.dart';

class CollectionsSelectionToolbar extends StatelessWidget {
  const CollectionsSelectionToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<LibraryController>();

    return Obx(() {
      if (!c.isSelectingCollections.value) return const SizedBox.shrink();

      final selectedCount = c.selectedCollectionIds.length;
      final totalCount = c.lastRawCollections.length;

      final bool isAllSelected = selectedCount == totalCount && totalCount > 0;

      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.borderStrong),
          ),
        ),
        child: Row(
          children: [
            // ⭐ Kaç tane seçili göster
            Text(
              '$selectedCount selected',
              style: AppTextStyles.bodyStrong,
            ),

            const Spacer(),

            // ⭐ SELECT ALL / UNSELECT ALL — TOGGLE
            TextButton(
              onPressed: () {
                if (isAllSelected) {
                  // Unselect All
                  c.selectedCollectionIds.clear();
                } else {
                  // Select All
                  c.selectAllCollections();
                }
              },
              child: Text(
                isAllSelected ? "Unselect All" : "Select All",
                style: AppTextStyles.bodyStrong.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // ⭐ DELETE
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppColors.error,
              onPressed: () async {
                await c.deleteSelectedCollections();
              },
            ),
          ],
        ),
      );
    });
  }
}
