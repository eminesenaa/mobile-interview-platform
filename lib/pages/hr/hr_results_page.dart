// ===================== File: hr_results_page.dart =====================
// Purpose:
// Global analytics page for all completed interviews
// =====================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/hr/widgets/results/results_completed_interviews.dart';
import 'package:interview_project/pages/hr/widgets/results/results_decision_breakdown.dart';
import 'package:interview_project/pages/hr/widgets/results/results_filter_bar.dart';
import 'package:interview_project/pages/hr/widgets/results/results_key_metrics.dart';
import 'package:interview_project/pages/hr/widgets/reviewed_detail/rd_insights_score_distribution.dart';

import '../../constants/constants.dart';
import 'controllers/hr_results_controller.dart';
import 'hr_interview_list_page.dart';

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
                avgScore: c.avgScore,
                acceptRate: c.acceptRate,
                highest: c.highestScore,
                lowest: c.lowestScore,
              ),

              const SizedBox(height: AppSpacing.xl),

              /// ================= DECISION =================
              Text("DECISION BREAKDOWN",
                  style: AppTextStyles.label.copyWith(fontSize: 12)),
              const SizedBox(height: AppSpacing.md),

              ResultsDecisionBreakdown(
                accepted: c.acceptedCount,
                rejected: c.rejectedCount,
              ),

              const SizedBox(height: AppSpacing.xl),

              /// ================= SCORE DISTRIBUTION =================
              Text("SCORE DISTRIBUTION",
                  style: AppTextStyles.label.copyWith(fontSize: 12)),
              const SizedBox(height: AppSpacing.md),

              RdInsightsScoreDistribution(
                distribution: c.scoreDistribution,
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
