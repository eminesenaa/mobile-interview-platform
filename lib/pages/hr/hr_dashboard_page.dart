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
import 'package:interview_project/pages/hr/widgets/hr_recent_activity_section.dart';

import '../../constants/constants.dart';
import 'controllers/hr_dashboard_controller.dart';
import 'create_interview_page.dart';
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
                onCreateInterview: () {
                  Get.to(() => const CreateInterviewPage());
                },
                onViewInterviews: () {
                  Get.to(() => const HRResultsPage());
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
