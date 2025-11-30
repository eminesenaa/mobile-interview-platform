// ===================== File: lib/pages/library/widgets/segmented_tab_bar.dart =====================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../../../constants/text_styles.dart';
import '../../../constants/constants.dart';
import '../controllers/library_controller.dart';

class LibrarySegmentedTabBar extends StatelessWidget {
  final TabController controller;
  const LibrarySegmentedTabBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: TabBar(
        controller: controller,
        onTap: (index) {
          final c = Get.find<LibraryController>();
          c.currentTab.value = LibraryTab.values[index];
          c.searchCtrl.clear();
          c.search.value = '';
          c.searchQuery.value = '';
        },

        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,

        labelPadding: const EdgeInsets.symmetric(vertical: 10),
        labelStyle: AppTextStyles.bodyStrong,
        unselectedLabelStyle: AppTextStyles.body,

        indicator: BoxDecoration(
          color: AppColors.primarySoftBackground,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),

        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textSecondary,

        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Collections'),
          Tab(text: 'Modules'), // Exams → Modules
        ],
      ),
    );
  }
}
