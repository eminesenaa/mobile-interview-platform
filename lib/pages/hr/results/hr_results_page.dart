// ===================== File: hr_results_page.dart =====================
// Purpose:
// Global analytics page for all completed interviews
// =====================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../../constants/constants.dart';
import '../controllers/hr_results_controller.dart';
import '../controllers/hr_interviews_controller.dart';
import '../interviews/hr_interview_list_page.dart';
import '../interviews/reviewed/widgets/rd_insights_score_distribution.dart';
import 'widgets/results_completed_interviews.dart';
import 'widgets/results_decision_breakdown.dart';
import 'widgets/results_filter_bar.dart';
import 'widgets/results_key_metrics.dart';

class HrResultsPage extends StatelessWidget {
  const HrResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(HrResultsController());

    return Scaffold(
      backgroundColor: AppColors.background,

      /// ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Results"),
      ),

      /// ================= BODY =================
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ================= FILTER =================
              ResultsFilterBar(
                selected: c.selectedFilter.value,
                onChanged: c.changeFilter,
              ),

              const SizedBox(height: AppSpacing.xl),

              /// ================= KEY METRICS =================
              Text("KEY METRICS",
                  style: AppTextStyles.label.copyWith(fontSize: 12)),
              const SizedBox(height: AppSpacing.md),

              ResultsKeyMetrics(
                avgScore: c.avgScore.value,
                acceptRate: c.acceptRate.value,
                highest: c.highestScore.value,
                lowest: c.lowestScore.value,
              ),

              const SizedBox(height: AppSpacing.xl),

              /// ================= DECISION =================
              Text("DECISION BREAKDOWN",
                  style: AppTextStyles.label.copyWith(fontSize: 12)),
              const SizedBox(height: AppSpacing.md),

              ResultsDecisionBreakdown(
                accepted: c.acceptedCount.value,
                rejected: c.rejectedCount.value,
              ),

              const SizedBox(height: AppSpacing.xl),

              /// ================= SCORE DISTRIBUTION =================
              Text("SCORE DISTRIBUTION",
                  style: AppTextStyles.label.copyWith(fontSize: 12)),
              const SizedBox(height: AppSpacing.md),

              RdInsightsScoreDistribution(
                distribution: c.scoreDistribution.value,
              ),

              const SizedBox(height: AppSpacing.xl),

              /// ================= COMPLETED =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("COMPLETED INTERVIEWS",
                      style: AppTextStyles.label.copyWith(fontSize: 12)),
                  GestureDetector(
                    onTap: () {
                      Get.put(HRInterviewsController()); // Ensure it exists
                      Get.to(() =>
                          const HRInterviewListPage(sectionKey: "reviewed"));
                    },
                    child: Text("See all",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        )),
                  )
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              ResultsCompletedInterviews(
                interviews: c.reviewedInterviews,
                onTap: c.openInsights,
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      }),
    );
  }
}
