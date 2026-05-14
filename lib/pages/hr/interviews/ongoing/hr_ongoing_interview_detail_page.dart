// ===================== File: hr_ongoing_interview_detail_page.dart =====================
// Purpose:
// Ongoing Interview Detail Page (READ-ONLY)
//
// Features:
// - Live banner
// - Interview info
// - Candidate sections
//
// ================================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/hr/interviews/widgets/hr_detail_header.dart';
import '../../../../../constants/constants.dart';
import '../../controllers/hr_ongoing_detail_controller.dart';
import 'widgets/od_candidate_section.dart';
import 'widgets/od_info_card.dart';
import 'widgets/od_live_banner.dart';

class HROngoingInterviewDetailPage extends StatelessWidget {
  final Map<String, dynamic> interview;

  const HROngoingInterviewDetailPage({
    super.key,
    required this.interview,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HROngoingDetailController(interview: interview));

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
        title: const Text("Interview"),
      ),

      // ================= BODY =================
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              HRDetailHeader(
                title: controller.title.value,
                status: "ongoing",
              ),

              const SizedBox(height: AppSpacing.md),

              // ================= LIVE =================
              OngoingLiveBanner(
                elapsed: controller.elapsedTime.value,
              ),

              const SizedBox(height: AppSpacing.md),

              // ================= INFO =================
              OngoingInfoCard(
                position: controller.position.value,
                timeRange: controller.timeRange.value,
                interviewId: controller.interviewId.value,
              ),

              const SizedBox(height: AppSpacing.lg),

              // ================= ACTIVE =================
              OngoingCandidateSection(
                title: "Currently in Interview",
                candidates: controller.activeCandidates,
              ),

              const SizedBox(height: AppSpacing.lg),

              // ================= WAITING =================
              OngoingCandidateSection(
                title: "Not Joined Yet",
                candidates: controller.waitingCandidates,
              ),

              const SizedBox(height: AppSpacing.lg),

              // ================= COMPLETED =================
              OngoingCandidateSection(
                title: "Completed",
                candidates: controller.completedCandidates,
              ),
            ],
          ),
        );
      }),
    );
  }
}
