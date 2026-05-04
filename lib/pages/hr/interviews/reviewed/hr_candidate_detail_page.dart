import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/constants.dart';
import '../../../exam/result/widgets/topic_charts.dart';
import '../../controllers/hr_reviewed_detail_controller.dart';
import 'widgets/rd_candidate_detail_header.dart';
import 'widgets/rd_final_decision_section.dart';
import 'widgets/rd_overall_score_section.dart';


// 👉 senin mevcut topic widget'ını import et
// import '../widgets/.../topic_performance_widget.dart';

/// ===============================================================
/// HR CANDIDATE DETAIL PAGE
/// ---------------------------------------------------------------
/// Shows evaluated candidate detail
///
/// IMPORTANT:
/// - Uses selectedCandidate from HrReviewedDetailController
/// - Fully backend-ready
///
/// TODO (Backend):
/// - Fetch candidate detail by ID
/// - Fetch topic performance
/// - Fetch evaluation message
/// ===============================================================
class HrCandidateDetailPage extends StatelessWidget {
  const HrCandidateDetailPage({super.key});

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
        title: const Text("Candidate Detail"),
      ),

      /// ================= BODY =================
      body: Obx(() {
        final result = c.selectedResult.value;

        if (result  == null) {
          return const Center(child: Text("No candidate selected"));
        }

        final candidate = result.candidate;
        final total = c.totalCandidates.value;

        final name = c.selectedName;
        final initials = c.selectedInitials;
        final decision = c.selectedDecision;
        final score = c.selectedScore;
        final rank = c.selectedRank;
        final subtitle = c.selectedSubtitle;
        final decisionDate = c.selectedDecisionDate;
        final message = c.selectedMessage;
        final topics = c.selectedTopics;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ================= HEADER =================
              RdCandidateDetailHeader(
                name: name,
                initials: initials,
                subtitle: subtitle,
                decision: decision,
                rank: rank,
              ),

              const SizedBox(height: AppSpacing.xl),

              /// ================= OVERALL SCORE =================
              RdOverallScoreSection(
                score: score,
                rank: rank,
                total: total,
              ),

              const SizedBox(height: AppSpacing.xl),

              /// ================= TOPIC PERFORMANCE =================
              Text(
                "TOPIC PERFORMANCE",
                style: AppTextStyles.label.copyWith(fontSize: 12),
              ),

              const SizedBox(height: AppSpacing.lg),

              TopicCharts(
                topicRatios: topics.map(
                      (key, value) => MapEntry(key, value / 100),
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              /// ================= FINAL DECISION =================
              RdFinalDecisionSection(
                decision: decision,
                date: decisionDate,
                message: message,
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      }),
    );
  }
}

