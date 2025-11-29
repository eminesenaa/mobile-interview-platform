// ===================== File: lib/pages/library/widgets/search_bar.dart =====================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../../../constants/text_styles.dart';
import '../../../constants/constants.dart';
import '../controllers/library_controller.dart';
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

          // SORT BUTTON
          RoundIconButton(
            icon: Icons.swap_vert_rounded,
            onTap: c.onSortPressed,
          ),

          const SizedBox(width: AppSpacing.sm),

          // ADD COLLECTION BUTTON
          RoundIconButton(
            icon: Icons.add_rounded,
            onTap: c.onCreateCollectionPressed,
          ),
        ],
      );
    });
  }
}
