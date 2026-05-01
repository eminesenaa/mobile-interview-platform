// ===================== File: open_positions_page.dart =====================
// Purpose:
// Displays all open job positions (Browse All)
//
// Features:
// - AppBar (standard)
// - Search bar
// - Filter chips
// - Section header
// - Job list (reuses existing card)
//
// IMPORTANT:
// - Uses OpenPositionsController
// - Uses existing job card (NO duplication)
// - Backend-ready structure
// ========================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/interview/widgets/interview_dashboard/id_open_position_card.dart';

import '../../../../constants/constants.dart';
import '../../controllers/open_positions_controller.dart';
import '../../widgets/open_positions/op_filter_chips_row.dart';
import '../../widgets/open_positions/op_search_bar.dart';
import '../../widgets/open_positions/op_section_header.dart';
import 'job_detail_page.dart';

class OpenPositionsPage extends StatelessWidget {
  const OpenPositionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OpenPositionsController());

    return Scaffold(
      backgroundColor: AppColors.background,

      // ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Open Positions",
          style: AppTextStyles.title,
        ),
      ),

      // ================= BODY =================
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,   // left
          AppSpacing.sm,   // top
          AppSpacing.lg,   // right
          AppSpacing.lg,   // bottom
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= SEARCH =================
            OpSearchBar(
              onChanged: controller.setSearchQuery,
            ),

            const SizedBox(height: AppSpacing.md),

            // ================= FILTERS =================
            Obx(() => OpFilterChipsRow(
                  filters: controller.filters,
                  selectedFilter: controller.selectedFilter.value,
                  onFilterSelected: controller.setFilter,
                )),

            const SizedBox(height: AppSpacing.lg),

            // ================= LIST =================
            Expanded(
              child: Obx(() {
                final jobs = controller.filteredJobs;

                // ================= EMPTY =================
                if (jobs.isEmpty) {
                  return Center(
                    child: Text(
                      "No positions found",
                      style: AppTextStyles.bodySmall,
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= HEADER =================
                    OpSectionHeader(
                      title: "Available Roles",
                      count: jobs.length,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // ================= LIST =================
                    Expanded(
                      child: ListView.separated(
                        itemCount: jobs.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final job = jobs[index];

                          return IdOpenPositionCard(
                            job: job,
                            onApply: () {
                              Get.to(
                                    () => const JobDetailPage(),
                                arguments: job,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
