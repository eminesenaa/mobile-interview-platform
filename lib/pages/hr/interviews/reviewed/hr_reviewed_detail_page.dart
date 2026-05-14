import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/hr/interviews/widgets/hr_detail_header.dart';
import '../../../../constants/constants.dart';
import '../../controllers/hr_reviewed_detail_controller.dart';
import '../needs_review/widgets/nd_view_all_button.dart';
import 'widgets/rd_insights_card.dart';
import 'widgets/rd_interview_info_card.dart';
import 'widgets/rd_review_summary.dart';
import 'widgets/rd_top_candidates_section.dart';

class HrReviewedDetailPage extends StatelessWidget {
  final Map<String, dynamic> interview;

  const HrReviewedDetailPage({
    super.key,
    required this.interview,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.put(
      HrReviewedDetailController(interview: interview),
    );

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
        title: const Text("Interview"),
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= HEADER =================
            Obx(
              () => HRDetailHeader(
                title: c.title.value,
                status: "completed",
                reviewStatus: "reviewed",
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            /// ================= INFO CARD =================
            Obx(
              () => RdInterviewInfoCard(
                position: c.position.value,
                totalCandidates: c.totalCandidates.value,
                date: c.date.value,
                startTime: c.startTime.value,
                endTime: c.endTime.value,
                interviewId: c.interviewId.value,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            /// ================= SUMMARY =================
            Obx(
              () => RdReviewSummary(
                total: c.totalCandidates.value,
                accepted: c.acceptedCount.value,
                rejected: c.rejectedCount.value,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            /// ================= TOP CANDIDATES =================
            Obx(
              () => RdTopCandidatesSection(
                candidates: c.rankedResults,
                onTap: c.openCandidateDetail,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            /// ================= VIEW ALL =================
            Obx(
              () => NdViewAllButton(
                text: "View all ${c.totalCandidates.value} candidates →",
                onTap: c.openAllCandidates,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            /// ================= INSIGHTS =================
            RdInsightsCard(
              onTap: c.openInsights,
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
