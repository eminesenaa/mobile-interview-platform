import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:interview_project/pages/hr/controllers/hr_needs_review_detail_controller.dart';
import 'package:interview_project/pages/hr/interviews/widgets/hr_detail_header.dart';


import '../../../../constants/constants.dart';
import 'widgets/nd_candidate_card.dart';
import 'widgets/nd_interview_info_card.dart';
import 'widgets/nd_section_label.dart';
import 'widgets/nd_view_all_button.dart';

/// ===============================================================
/// HR NEEDS REVIEW DETAIL PAGE
/// ---------------------------------------------------------------
/// Amaç:
/// - Needs Review durumundaki interview detayını göstermek
///
/// İçerik:
/// 1. Header
/// 2. Interview info card (controller'dan gelir)
/// 3. Top candidates (controller'dan gelir)
/// 4. View all button
///
/// ÖNEMLİ:
/// - Tüm veri controller’dan gelir ✔
/// - Backend entegrasyonuna hazır yapı
/// ===============================================================
class HrNeedsReviewDetailPage extends StatelessWidget {
  final Map<String, dynamic> interview;

  const HrNeedsReviewDetailPage({
    super.key,
    required this.interview,
  });

  @override
  Widget build(BuildContext context) {
    /// =========================
    /// CONTROLLER INIT
    /// =========================
    final controller = Get.put(HrNeedsReviewDetailController(interview: interview));

    return Scaffold(
      backgroundColor: AppColors.background,

      /// =========================
      /// APP BAR
      /// =========================
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

      /// =========================
      /// BODY
      /// =========================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= HEADER =================
            Obx(
              () => HRDetailHeader(
                title: controller.title.value,
                status: "completed",
                reviewStatus: controller.overallReviewStatus,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            /// =========================
            /// INTERVIEW INFO CARD
            /// =========================
            Obx(
              () => NdInterviewInfoCard(
                dateText: controller.date.value,
                candidatesText: controller.candidatesCompletedText.value,
                interviewId: controller.interviewId.value,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            /// =========================
            /// SECTION LABEL
            /// =========================
            const NdSectionLabel(
              title: "TOP CANDIDATES",
              trailing: "Highest score first",
            ),

            const SizedBox(height: AppSpacing.sm),

            /// =========================
            /// TOP CANDIDATES LIST
            /// =========================
            Obx(
              () => Column(
                children: List.generate(
                  controller.topCandidates.length,
                  (index) {
                    final c = controller.topCandidates[index];

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.sm,
                      ),
                      child: NdCandidateCard(
                        rank: index + 1,
                        name: c["name"],
                        initials: c["initials"],
                        score: c["score"],
                        decision: c["decision"],
                        onReview: () => controller.openCandidateDetail(c),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            /// =========================
            /// VIEW ALL BUTTON
            /// =========================
            Obx(
              () => NdViewAllButton(
                text: "View all ${controller.totalCandidateCount} candidates →",
                onTap: controller.openAllCandidates,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
