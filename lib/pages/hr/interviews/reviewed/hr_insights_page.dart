// ===================== File: hr_insights_page.dart =====================
// Purpose:
// Displays interview insights & analytics
//
// IMPORTANT:
// - Uses HrReviewedDetailController
// - Backend-ready
//
// TODO (Backend):
// - Fetch aggregated metrics
// ======================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/constants.dart';
import '../../controllers/hr_reviewed_detail_controller.dart';
import 'widgets/rd_insights_decision_breakdown.dart';
import 'widgets/rd_insights_key_metrics.dart';
import 'widgets/rd_insights_score_distribution.dart';
import 'widgets/rd_insights_topic_scores.dart';

class HrInsightsPage extends StatelessWidget {
  const HrInsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HrReviewedDetailController>();

    return Scaffold(
      backgroundColor: AppColors.background,

      /// ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        title: const Text("Insights"),
      ),

      /// ================= BODY =================
      body: Obx(() {
        /// 🔥 CONTROLLER DATA
        final avgScore = c.avgScore;
        final acceptRate = c.acceptRate;
        final highest = c.highestScore;
        final lowest = c.lowestScore;

        final accepted = c.acceptedCount.value;
        final rejected = c.rejectedCount.value;

        final topics = c.topicAverages;
        final distribution = c.scoreDistribution;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ================= KEY METRICS =================
              RdInsightsKeyMetrics(
                avgScore: avgScore,
                acceptRate: acceptRate.toDouble(),
                highest: highest,
                lowest: lowest,
              ),

              const SizedBox(height: AppSpacing.xl),

              /// ================= DECISION BREAKDOWN =================
              RdInsightsDecisionBreakdown(
                accepted: accepted,
                rejected: rejected,
              ),

              const SizedBox(height: AppSpacing.xl),

              /// ================= TOPIC SCORES =================
              RdInsightsTopicScores(
                topics: topics,
              ),

              const SizedBox(height: AppSpacing.xl),

              /// ================= SCORE DISTRIBUTION =================
              RdInsightsScoreDistribution(
                distribution: distribution,
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      }),
    );
  }
}
