// ===================== File: applications_page.dart =====================
// Purpose:
// Displays all candidate applications (View All page)
//
// Features:
// - AppBar (standard)
// - Search bar (title-based search)
// - Filter chips (All, Accepted, Pending, Rejected)
// - Sorted application list
// - Empty state
//
// IMPORTANT:
// - Uses ApplicationsController
// - Reuses IdApplicationItem
// - Sorting priority:
//   Accepted → Pending → Rejected
//
// ========================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/constants.dart';

// ================= CONTROLLER =================
import '../../controllers/applications_controller.dart';

// ================= WIDGETS =================
import '../../widgets/applications/ap_empty_state.dart';
import '../../widgets/applications/ap_filter_row.dart';
import '../../widgets/applications/ap_search_bar.dart';

// ================= REUSED CARD =================
import '../../widgets/applications/ap_section_label.dart';
import '../../widgets/interview_dashboard/id_application_item.dart';
import 'application_detail_page.dart';

class ApplicationsPage extends StatelessWidget {
  const ApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ApplicationsController());

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
          onPressed: () => Get.back(),
        ),
        title: Text(
          "My Applications",
          style: AppTextStyles.title,
        ),
      ),

      // =====================================================
      // BODY
      // =====================================================
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, // left
          AppSpacing.sm, // top
          AppSpacing.lg, // right
          AppSpacing.lg, // bottom
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =====================================================
            // SEARCH BAR
            // =====================================================
            ApSearchBar(
              onChanged: controller.setSearchQuery,
            ),

            const SizedBox(height: AppSpacing.md),

            // =====================================================
            // FILTER ROW
            // =====================================================
            Obx(() => ApFilterRow(
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
                final applications = controller.filteredApplications;

                // ================= EMPTY STATE =================
                if (applications.isEmpty) {
                  return const ApEmptyState();
                }

                // ================= GROUPING =================
                final accepted = applications
                    .where((e) => e["status"] == "accepted")
                    .toList();

                final pending = applications
                    .where((e) => e["status"] == "pending")
                    .toList();

                final rejected = applications
                    .where((e) => e["status"] == "rejected")
                    .toList();

                // ================= LIST =================
                return ListView(
                  children: [
                    // ================= ACCEPTED =================
                    if (accepted.isNotEmpty) ...[
                      ApSectionLabel(
                        title: "Accepted",
                        count: accepted.length,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...accepted.map((app) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.md),
                            child: IdApplicationItem(
                              application: app,
                              onTap: () {
                                Get.to(() => ApplicationDetailPage(),
                                    arguments: app);
                              },
                            ),
                          )),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // ================= PENDING =================
                    if (pending.isNotEmpty) ...[
                      ApSectionLabel(
                        title: "Pending",
                        count: pending.length,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...pending.map((app) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.md),
                            child: IdApplicationItem(
                              application: app,
                              onTap: () {
                                Get.to(() => ApplicationDetailPage(),
                                    arguments: app);
                              },
                            ),
                          )),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // ================= REJECTED =================
                    if (rejected.isNotEmpty) ...[
                      ApSectionLabel(
                        title: "Rejected",
                        count: rejected.length,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...rejected.map((app) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.md),
                            child: IdApplicationItem(
                              application: app,
                              onTap: () {
                                Get.to(() => ApplicationDetailPage(),
                                    arguments: app);
                              },
                            ),
                          )),
                    ],
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
