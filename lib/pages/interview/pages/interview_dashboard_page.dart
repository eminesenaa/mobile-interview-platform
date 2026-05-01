// ===================== File: interview_dashboard_page.dart =====================
// Purpose:
// Candidate Interview Dashboard Page
//
// Structure:
// - Header
// - Stats row
// - Open positions
// - Applications
// - Upcoming interview
// - Results
//
// Architecture:
// - GetX Controller
// - Fully modular widgets
//
// IMPORTANT:
// - Uses InterviewDashboardController
// - Uses reusable widgets
// - Backend-ready
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/constants.dart';

// CONTROLLER
import '../controllers/interview_dashboard_controller.dart';

// WIDGETS
import '../widgets/interview_dashboard/id_dashboard_hero.dart';
import '../widgets/interview_dashboard/id_stats_row.dart';
import '../widgets/interview_dashboard/id_section_header.dart';
import '../widgets/interview_dashboard/id_open_position_card.dart';
import '../widgets/interview_dashboard/id_application_item.dart';
import '../widgets/interview_dashboard/id_interview_card.dart';
import '../widgets/interview_dashboard/id_result_item.dart';
import 'open_positions/job_detail_page.dart';
import 'open_positions/open_positions_page.dart';

class InterviewDashboardPage extends StatelessWidget {
  const InterviewDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InterviewDashboardController());

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
          "Interviews",
          style: AppTextStyles.headline,
        ),
      ),

      // ================= BODY =================
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= DASHBOARD HERO =================
                const IdDashboardHero(),

                const SizedBox(height: AppSpacing.lg),

                // ================= STATS =================
                IdStatsRow(
                  applications: controller.activeApplicationsCount,
                  interviews: controller.readyInterviewsCount,
                  results: controller.pendingResultsCount,
                ),

                const SizedBox(height: AppSpacing.xl),

                // =====================================================
                // OPEN POSITIONS
                // =====================================================
                IdSectionHeader(
                  title: "Open Positions",
                  actionText: "Browse all",
                  onTap: () {
                    Get.to(() => const OpenPositionsPage());
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                ...controller.openPositions.map((job) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: IdOpenPositionCard(
                      job: job,
                      onApply: () {
                        Get.to(
                              () => const JobDetailPage(),
                          arguments: job,
                        );
                      },
                    ),
                  );
                }),

                const SizedBox(height: AppSpacing.xl),

                // =====================================================
                // MY APPLICATIONS
                // =====================================================
                IdSectionHeader(
                  title: "My Applications",
                  actionText: "View all",
                  onTap: () {},
                ),

                const SizedBox(height: AppSpacing.md),

                ...controller.applications.map((app) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: IdApplicationItem(
                      application: app,
                    ),
                  );
                }),

                const SizedBox(height: AppSpacing.xl),

                // =====================================================
                // UPCOMING INTERVIEW
                // =====================================================
                if (controller.upcomingInterview.value != null) ...[
                  const IdSectionHeader(
                    title: "Upcoming Interview",
                  ),
                  const SizedBox(height: AppSpacing.md),
                  IdInterviewCard(
                    interview: controller.upcomingInterview.value!,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],

                // =====================================================
                // INTERVIEW RESULTS
                // =====================================================
                IdSectionHeader(
                  title: "Interview Results",
                  actionText: "View all",
                  onTap: () {},
                ),

                const SizedBox(height: AppSpacing.md),

                ...controller.results.map((result) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: IdResultItem(
                      result: result,
                    ),
                  );
                }),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        }),
      ),
    );
  }
}
