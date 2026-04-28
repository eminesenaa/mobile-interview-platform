// ===================== File: hr_dashboard_page.dart =====================
// Purpose:
// Clean & modular HR Dashboard page
//
// Structure:
// - Flat background (no gradient)
// - Uses modular widgets
// - Fully design-system compliant
//
// Widgets Used:
// - HRDashboardHeader
// - HRDashboardStatsRow
// - HRQuickActionsSection
// ========================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/hr/cip_select_job_posting_page.dart';
import 'package:interview_project/pages/hr/hr_interviews_page.dart';
import 'package:interview_project/pages/hr/widgets/hr_recent_activity_section.dart';

import '../../constants/constants.dart';
import 'controllers/create_interview_controller.dart';
import 'controllers/hr_dashboard_controller.dart';
import 'hr_job_postings_page.dart';
import 'hr_results_page.dart';

// Widgets
import 'widgets/hr_dashboard_header.dart';
import 'widgets/hr_dashboard_stats_row.dart';
import 'widgets/hr_quick_actions_section.dart';

class HRDashboardPage extends StatelessWidget {
  const HRDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HRDashboardController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===============================
              // HEADER
              // ===============================
              Obx(() => HRDashboardHeader(
                    companyName: controller.companyName.value,
                    initials: controller.initials.value,
                  )),

              const SizedBox(height: AppSpacing.xl),

              // ===============================
              // STATS
              // ===============================
              Obx(() => HRDashboardStatsRow(
                    interviewCount: controller.interviewCount.value,
                    candidateCount: controller.candidateCount.value,
                  )),

              const SizedBox(height: AppSpacing.xl),

              // ===============================
              // QUICK ACTIONS
              // ===============================
              HRQuickActionsSection(
                onManagePostings: () {
                  Get.to(() => const HRJobPostingsPage());
                },
                onCreateInterview: () {
                  Get.to(
                        () => const CipSelectJobPostingPage(),
                    binding: BindingsBuilder(() {
                      Get.put(CreateInterviewController());
                    }),
                  );
                },
                onViewInterviews: () {
                  Get.to(() => const HRInterviewsPage());
                },
                onViewResults: () {
                  Get.to(() => const HrResultsPage());
                },
                onViewCandidates: () {
                  Get.snackbar("TODO", "Candidates Page");
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              const HRRecentActivitySection(),
            ],
          ),
        ),
      ),
    );
  }
}
