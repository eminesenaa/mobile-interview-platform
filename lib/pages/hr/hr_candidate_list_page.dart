import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/hr/widgets/needsreview_detail/nd_active_filter_chip.dart';
import 'package:interview_project/pages/hr/widgets/needsreview_detail/nd_candidate_card.dart';
import 'package:interview_project/pages/hr/widgets/needsreview_detail/nd_filter_container.dart';
import 'package:interview_project/pages/hr/widgets/needsreview_detail/nd_score_filter.dart';
import 'package:interview_project/pages/hr/widgets/needsreview_detail/nd_topic_slider.dart';
import 'package:interview_project/pages/hr/widgets/needsreview_detail/nd_topn_slider.dart';

import '../../constants/constants.dart';
import 'controllers/hr_needs_review_detail_controller.dart';

/// ===============================================================
/// HR CANDIDATE LIST PAGE (FILTER PAGE)
/// ---------------------------------------------------------------
/// Amaç:
/// - Tüm adayları listelemek
/// - Filter sistemi ile daraltmak
///
/// İçerik:
/// 1. Filter container
/// 2. Active filters
/// 3. Filtered candidate list
///
/// NOT:
/// - Controller ile çalışır
/// - Backend-ready yapı
/// ===============================================================
class HrCandidateListPage extends StatelessWidget {
  const HrCandidateListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HrNeedsReviewDetailController>();

    return Scaffold(
      backgroundColor: AppColors.background,

      /// ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        title: const Text("All Candidates"),
      ),

      /// ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= FILTER CONTAINER =================
            Obx(
              () => NdFilterContainer(
                onClear: controller.clearFilters,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// -------- TOP N --------
                    NdTopNSlider(
                      value: controller.topN.value,
                      max: controller.totalCandidateCount,
                      onChanged: controller.updateTopN,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    /// -------- MIN SCORE --------
                    Text(
                      "Minimum Score".toUpperCase(),
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    NdScoreFilter(
                      selected: controller.minScore.value,
                      onSelected: controller.updateMinScore,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    /// -------- TOPIC THRESHOLDS --------
                    Text(
                      "TOPIC THRESHOLDS",
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    Column(
                      children: controller.topicThresholds.entries
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final e = entry.value;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: NdTopicSlider(
                            topic: e.key,
                            value: e.value,
                            color: controller.getTopicColor(index),
                            onChanged: (val) =>
                                controller.updateTopicThreshold(e.key, val),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            /// ================= ACTIVE FILTERS =================
            Obx(() {
              final filters = controller.activeFilters;

              if (filters.isEmpty) return const SizedBox();

              return Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: filters.map((f) {
                  return NdActiveFilterChip(
                    label: f.label,
                    onRemove: f.onRemove,
                  );
                }).toList(),
              );
            }),

            const SizedBox(height: AppSpacing.md),

            /// ================= RESULT INFO + SORT =================
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Showing ${controller.filteredCandidates.length} of ${controller.totalCandidateCount} candidates",
                    style: AppTextStyles.bodySmall,
                  ),
                  Text(
                    "Sort: Score ↓",
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            /// ================= CANDIDATE LIST =================
            Obx(
              () => Column(
                children: List.generate(
                  controller.filteredCandidates.length,
                  (index) {
                    final c = controller.filteredCandidates[index];

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.sm,
                      ),
                      child: NdCandidateCard(
                        rank: index + 1,
                        name: c["name"],
                        initials: c["initials"],
                        score: c["score"],
                        topics: c["topics"],
                        onReview: () => controller.openCandidateDetail(c),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
