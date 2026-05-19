// ===================== File: interview_results_page.dart =====================
// Purpose:
// Displays all interview widgets (View All page)
//
// Features:
// - AppBar (standard)
// - Search bar (title-based search)
// - Filter chips (All, Accepted, Pending, Rejected)
// - Grouped widgets list
// - Empty state
//
// IMPORTANT:
// - Uses InterviewResultsController
// - Reuses IdResultItem
// - Sorting priority:
//   Accepted → Pending → Rejected
//
// TODO (Backend):
// - Navigate to Interview Detail Page
// ============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/constants.dart';

// ================= CONTROLLER =================
import '../../controllers/interview_results_controller.dart';
import '../../widgets/results/ir_empty_state.dart';
import '../../widgets/results/ir_filter_row.dart';
import '../../widgets/results/ir_results_list.dart';
import '../../widgets/results/ir_search_bar.dart';
import 'interview_result_detail_page.dart';

// ================= WIDGETS =================


class InterviewResultsPage extends StatelessWidget {
  const InterviewResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InterviewResultsController());

    return Scaffold(
      backgroundColor: AppColors.background,

      // =====================================================
      // APP BAR
      // =====================================================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Interview Results",
          style: AppTextStyles.title,
        ),
      ),

      // =====================================================
      // BODY
      // =====================================================
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =====================================================
            // SEARCH BAR
            // =====================================================
            IrSearchBar(
              onChanged: controller.setSearchQuery,
            ),

            const SizedBox(height: AppSpacing.md),

            // =====================================================
            // FILTER ROW
            // =====================================================
            Obx(() => IrFilterRow(
                  filters: controller.filters,
                  selectedFilter: controller.selectedFilter.value,
                  onSelect: controller.setFilter,
                )),

            const SizedBox(height: AppSpacing.lg),

            // =====================================================
            // LIST
            // =====================================================
            Expanded(
              child: Obx(() {
                final results = controller.filteredResults;

                // ================= EMPTY =================
                if (results.isEmpty) {
                  return const IrEmptyState();
                }

                // ================= LIST =================
                return IrResultsList(
                  results: results,
                  onTap: (result) {
                    Get.to(
                      () => InterviewResultDetailPage(),
                      arguments: result,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
