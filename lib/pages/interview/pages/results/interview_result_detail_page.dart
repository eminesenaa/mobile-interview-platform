// ===================== File: interview_result_detail_page.dart =====================
// Purpose:
// Displays Interview Result Detail (Accepted / Rejected / Pending)
//
// Features:
// - Shared header
// - Status-based content
// - Reuses TopicCharts & ScoreCircle
//
// IMPORTANT:
// - Expects Map<String, dynamic> via Get.arguments
// - Uses InterviewResultsController helpers
//
// TODO (Backend):
// - Replace Map with full Interview + Result models
// - Use real aiResult.topicRatios
// - Navigate Review button to exam review page
// ================================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/interview/widgets/interview/submitted/is_steps_card.dart';

import '../../../../constants/constants.dart';

// ================= CONTROLLER =================
import '../../../../models/interview_result.dart';
import '../../controllers/interview_results_controller.dart';

// ================= WIDGETS =================
import '../../widgets/results/detail/ir_detail_header.dart';
import '../../widgets/results/detail/ir_hr_message_section.dart';
import '../../widgets/results/detail/ir_pending_section.dart';
import '../../widgets/results/detail/ir_review_button.dart';
import '../../widgets/results/detail/ir_score_section.dart';
import '../../widgets/results/detail/ir_topic_section.dart';
import '../../widgets/results/ir_section_label.dart';

class InterviewResultDetailPage extends StatelessWidget {
  const InterviewResultDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InterviewResultsController());

    // ================= ARGUMENT =================
    final Map<String, dynamic> item = Get.arguments;
    final InterviewResult result = item["result"];

    final status = controller.getStatus(item);

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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          item["title"] ?? "",
          style: AppTextStyles.title,
        ),
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =====================================================
            // HEADER
            // =====================================================
            IrDetailHeader(
              company: item["company"] ?? "",
              location: item["location"] ?? "",
              date: controller.formatDate(item["startTime"]),
              timeRange: controller.formatTimeRange(
                item["startTime"],
                item["endTime"],
              ),
              status: status,
              rankText:
                  status != "pending" ? "Rank #${result.correctCount}" : null,
            ),

            const SizedBox(height: AppSpacing.xl),

            // =====================================================
            // ACCEPTED / REJECTED FLOW
            // =====================================================
            if (status != "pending") ...[
              // ================= SCORE =================
              const IrSectionLabel(title: "OVERALL SCORE"),
              const SizedBox(height: AppSpacing.md),

              IrOverallScoreSection(
                score: result.score ?? 0,
                status: status,
                rank: result.correctCount, // veya gerçek rank
                total: 100,
              ),

              const SizedBox(height: AppSpacing.xl),

              // ================= TOPICS =================
              const IrSectionLabel(title: "TOPIC PERFORMANCE"),
              const SizedBox(height: AppSpacing.lg),

              IrTopicSection(
                topicRatios: controller.getTopicRatios(result),
              ),

              const SizedBox(height: AppSpacing.xs),

              // ================= HR MESSAGE =================
              if (result.hrMessage != null) ...[
                IrHrMessageSection(
                  title: status == "accepted"
                      ? "MESSAGE FROM HR"
                      : "FEEDBACK FROM HR",
                  message: result.hrMessage!,
                  sender: "HR Team",
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              // ================= REVIEW BUTTON =================
              const IrReviewButton(),
            ],

            // =====================================================
            // PENDING FLOW
            // =====================================================
            if (status == "pending") ...[
              const IrPendingSection(),
              const SizedBox(height: AppSpacing.xl),
              const IsStepsCard(),
            ],
          ],
        ),
      ),
    );
  }
}
