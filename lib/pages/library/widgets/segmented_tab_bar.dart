// ===================== File: lib/pages/library/widgets/segmented_tab_bar.dart =====================

import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../constants/text_styles.dart';
import '../../../constants/constants.dart';

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
